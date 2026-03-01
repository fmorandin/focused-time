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

    // MARK: - State Change Callback

    /// Called after every state mutation so the ViewModel (or any observer) can sync.
    var onStateChange: (() -> Void)?

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

    private let systemSoundID: SystemSoundID = 1009

    private var isAutoStartEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.autoStartToggle)
    }
    private var isPlaySoundEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.playTimerSounds)
    }

    // MARK: - Initializer

    init(
        timerModel: TimerModelProtocol,
        timerFactory: RepeatingTimerFactoryProtocol = FoundationRepeatingTimerFactory(),
        nowProvider: @escaping () -> Date = Date.init,
        localNotificationManager: LocalNotificationManaging = LocalNotificationManager(),
        soundPlayer: SystemSoundPlaying = AudioSystemSoundPlayer(),
        notificationFlagStore: NotificationFlagStoring = UserDefaults.standard
    ) {
        Self.logger.notice("🛠 Initializing TimerUseCase.")

        self.timerModel = timerModel
        self.timerFactory = timerFactory
        self.nowProvider = nowProvider
        self.localNotificationManager = localNotificationManager
        self.soundPlayer = soundPlayer
        self.notificationFlagStore = notificationFlagStore

        let savedFocusedTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        self.totalTime = savedFocusedTime
        self.counter = savedFocusedTime
        self.totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
    }

    // MARK: - Public Methods

    /// Starts a 1-second repeating tick. Transitions to the next phase when counter reaches zero.
    func startTimer() {
        Self.logger.notice("▶️ Starting timer.")
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
        onStateChange?()
    }

    /// Resets all state back to the initial focused phase, reloading settings from the model.
    func resetUpdateTimer() {
        Self.logger.notice("🔄 Resetting timer.")
        timer?.invalidate()
        timerState = .initial
        timerType = .focused
        timerTo = 1.0
        numberOfCompletedCycles = 0
        let focusedTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        counter = focusedTime
        totalTime = focusedTime
        totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
        onStateChange?()
    }

    /// Saves remaining time and schedules a local notification when the app enters background.
    func moveAppToBackground() {
        Self.logger.notice("👋🏻 Moving app to the background.")
        if timerState == .running {
            timerModel.saveMoveToBackgroundTime(remainingTime: counter)
            localNotificationManager.scheduleLocalNotification(remainingTime: Double(counter))
        }
    }

    /// Cancels pending notifications and recalculates the remaining time when the app returns to foreground.
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
            counter = totalRemainingTime <= 0 ? 0 : totalRemainingTime
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

        if notificationFlagStore.bool(forKey: UserDefaultKeys.isNotification) {
            notificationFlagStore.set(false, forKey: UserDefaultKeys.isNotification)
        } else if isPlaySoundEnabled {
            soundPlayer.playSystemSound(systemSoundID)
        }

        timerTo = 1.0
        timerState = .initial

        handleCompletedCycle()

        if numberOfCompletedCycles == totalNumberOfCycles {
            Self.logger.notice("🥳 Completed all cycles — transitioning to long break.")
            applyTimerType(.longBreak)
        } else if timerType == .focused {
            Self.logger.notice("🤓 Focus done — transitioning to short break.")
            applyTimerType(.focused)
        } else {
            Self.logger.notice("😮‍💨 Break done — transitioning back to focus.")
            applyTimerType(.shortBreak)
        }
    }

    private func handleCompletedCycle() {
        if timerType == .focused {
            Self.logger.notice("👏🏻 Cycle completed.")
            numberOfCompletedCycles += 1
        } else if timerType == .longBreak {
            Self.logger.notice("💪🏻 Long break done — resetting cycles.")
            numberOfCompletedCycles = 0
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
