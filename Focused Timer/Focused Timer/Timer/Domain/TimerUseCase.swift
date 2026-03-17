//
//  TimerUseCase.swift
//  Focused Timer
//
//  Domain layer for Pomodoro timer logic.
//  No SwiftUI, no UIKit — pure business logic that can be consumed by ViewModels,
//  App Intents, Widgets, or Watch targets without modification.
//

import AudioToolbox
import Foundation
import os

final class TimerUseCase {

    // MARK: - State (source of truth for all timer state)

    var counter: Int
    private(set) var totalTime: Int
    private(set) var timerState: TimerState = .initial
    private(set) var timerType: TimerType = .focused
    private(set) var timerTo: CGFloat = 1.0
    private(set) var numberOfCompletedCycles: Int = 0
    private(set) var totalNumberOfCycles: Int
    private var previousPhaseWasFocus = false

    // MARK: - State Change Callback

    /// Called after every state mutation so the ViewModel (or any observer) can sync.
    var onStateChange: (() -> Void)?

    /// Called when a full Pomodoro set completes (long break timer expires).
    /// Observers can use this to trigger a review request or analytics event.
    var onCycleSetComplete: (() -> Void)?

    // MARK: - Computed Settings

    /// Whether the "keep screen on" preference is currently enabled.
    var isKeepScreenOnEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.keepScreenOn)
    }

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TimerUseCase.self)
    )

    private var timer: RepeatingTimerProtocol?
    private let timerModel: TimerModelProtocol
    private let timerFactory: RepeatingTimerFactoryProtocol
    private let nowProvider: () -> Date
    private let localNotificationManager: LocalNotificationManaging
    private let soundPlayer: SystemSoundPlaying
    private let notificationFlagStore: NotificationFlagStoring
    private let alarmScheduler: AlarmScheduling?

    private let systemSoundID: SystemSoundID = 1009

    private var isAutoStartEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.autoStartToggle)
    }
    private var isAlarmEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.enableAlarm)
    }
    private var isPlaySoundEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.playTimerSounds)
    }
    private var isNotificationsEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.enableNotifications)
    }

    // MARK: - Initializer

    init(
        timerModel: TimerModelProtocol,
        timerFactory: RepeatingTimerFactoryProtocol = FoundationRepeatingTimerFactory(),
        nowProvider: @escaping () -> Date = Date.init,
        localNotificationManager: LocalNotificationManaging = LocalNotificationManager(),
        soundPlayer: SystemSoundPlaying = AudioSystemSoundPlayer(),
        notificationFlagStore: NotificationFlagStoring = UserDefaults.standard,
        alarmScheduler: AlarmScheduling? = nil
    ) {
        Self.logger.notice("🛠 Initializing TimerUseCase.")

        self.timerModel = timerModel
        self.timerFactory = timerFactory
        self.nowProvider = nowProvider
        self.localNotificationManager = localNotificationManager
        self.soundPlayer = soundPlayer
        self.notificationFlagStore = notificationFlagStore
        self.alarmScheduler = alarmScheduler

        let startingType = timerModel.getStartingTimerType()
        self.timerType = startingType
        let startingTime = timerModel.getTime(for: startingType.userDefaultKey)
        self.totalTime = startingTime
        self.counter = startingTime
        self.totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
    }

    // MARK: - Public Methods

    /// Starts a 1-second repeating tick. Transitions to the next phase when counter reaches zero.
    func startTimer() {
        Self.logger.notice("▶️ Starting timer.")
        timerState = .running
        alarmScheduler?.cancelAlarm()
        if isAlarmEnabled {
            alarmScheduler?.scheduleAlarm(remainingTime: TimeInterval(counter))
        }
        timer?.invalidate()
        timer = timerFactory.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] scheduledTimer in
            guard let self else { return }

            if self.counter <= self.totalTime && self.counter != 0 {
                self.tick()
                self.onStateChange?()
            } else {
                self.changeTimerMode()

                if self.isAutoStartEnabled {
                    self.startTimer()
                }

                scheduledTimer.invalidate()
                self.onStateChange?()
            }
        }
    }

    /// Pauses the timer, preserving the current counter value.
    func pauseTimer() {
        Self.logger.notice("⏸ Pausing timer.")
        timerState = .paused
        timer?.invalidate()
        alarmScheduler?.cancelAlarm()
        onStateChange?()
    }

    /// Resets all state back to the initial focused phase, reloading settings from the model.
    func resetUpdateTimer() {
        Self.logger.notice("🔄 Resetting timer.")
        timer?.invalidate()
        alarmScheduler?.cancelAlarm()
        timerState = .initial
        timerTo = 1.0
        numberOfCompletedCycles = 0
        previousPhaseWasFocus = false
        let startingType = timerModel.getStartingTimerType()
        timerType = startingType
        let startingTime = timerModel.getTime(for: startingType.userDefaultKey)
        counter = startingTime
        totalTime = startingTime
        totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
        onStateChange?()
    }

    /// Saves remaining time and schedules a local notification when the app enters background.
    func moveAppToBackground() {
        Self.logger.notice("👋🏻 Moving app to the background.")
        if timerState == .running {
            timerModel.saveMoveToBackgroundTime(remainingTime: counter)
            if isNotificationsEnabled {
                localNotificationManager.scheduleLocalNotification(remainingTime: Double(counter))
            }
        }
    }

    /// Cancels pending notifications and recalculates the remaining time when the app returns to foreground.
    /// If the timer expired while in background, transitions to the next phase immediately instead
    /// of waiting for the next Foundation timer tick, preventing a momentary stale-state flash in the UI.
    func moveAppToForeground() {
        Self.logger.notice("👋🏻 Moving app to the foreground.")
        localNotificationManager.clearScheduledNotifications()

        if timerState == .running {
            Self.logger.notice("🏃🏻‍♂️ Timer is running.")
            let (savedRemainingTime, savedTimestampBackground) = timerModel.getSavedTimes()

            guard let remainingTime = savedRemainingTime,
                  let timestampBackground = savedTimestampBackground else { return }

            let timeInBackground = Int(DateInterval(start: timestampBackground, end: nowProvider()).duration)
            let totalRemainingTime = remainingTime - timeInBackground

            if totalRemainingTime <= 0 {
                Self.logger.notice("⏰ Timer expired in background — advancing phase immediately.")
                timer?.invalidate()
                timer = nil
                changeTimerMode()
                if isAutoStartEnabled {
                    startTimer()
                }
            } else {
                counter = totalRemainingTime
            }
            onStateChange?()
        }
    }

    // MARK: - Private Methods

    private func tick() {
        Self.logger.notice("⏲ Tick — decrementing counter.")
        timerState = .running
        counter -= 1
        timerTo = CGFloat(counter) / CGFloat(totalTime)
    }

    private func changeTimerMode() {
        Self.logger.notice("🆕 Changing timer mode.")
        alarmScheduler?.cancelAlarm()

        if notificationFlagStore.bool(forKey: UserDefaultKeys.isNotification) {
            notificationFlagStore.set(false, forKey: UserDefaultKeys.isNotification)
        } else if isPlaySoundEnabled {
            soundPlayer.playSystemSound(systemSoundID)
        }

        timerTo = 1.0
        timerState = .initial

        switch timerType {
        case .focused where numberOfCompletedCycles + 1 == totalNumberOfCycles:
            // Last focus session — skip short break and go straight to long break.
            Self.logger.notice("🥳 Completed all cycles — transitioning to long break.")
            numberOfCompletedCycles += 1
            previousPhaseWasFocus = false
            applyTimerType(.longBreak)

        case .focused:
            Self.logger.notice("🤓 Focus done — transitioning to short break.")
            previousPhaseWasFocus = true
            applyTimerType(.focused)

        case .shortBreak:
            // Only count the cycle if this short break followed a focus session.
            // An initial short break (starting timer type) has no preceding focus.
            if previousPhaseWasFocus {
                Self.logger.notice("👏🏻 Cycle completed — transitioning back to focus.")
                numberOfCompletedCycles += 1
            } else {
                Self.logger.notice("😮‍💨 Initial break done — transitioning to focus.")
            }
            previousPhaseWasFocus = false
            applyTimerType(.shortBreak)

        case .longBreak:
            Self.logger.notice("💪🏻 Long break done — resetting cycles.")
            numberOfCompletedCycles = 0
            previousPhaseWasFocus = false
            onCycleSetComplete?()
            applyTimerType(.shortBreak)
        }
    }

    private func applyTimerType(_ completedType: TimerType) {
        Self.logger.notice("🔃 Applying next timer type after completing \(completedType.rawValue).")
        switch completedType {
        case .focused:
            timerType = .shortBreak
            let duration = timerModel.getTime(for: UserDefaultKeys.shortBreakTime)
            counter = duration
            totalTime = duration

        case .shortBreak:
            timerType = .focused
            let duration = timerModel.getTime(for: UserDefaultKeys.focusedTime)
            counter = duration
            totalTime = duration

        case .longBreak:
            timerType = .longBreak
            let duration = timerModel.getTime(for: UserDefaultKeys.longBreakTime)
            counter = duration
            totalTime = duration
        }
    }
}
