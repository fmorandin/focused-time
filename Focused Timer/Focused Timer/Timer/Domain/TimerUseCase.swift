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

// MARK: - Widget State Reading Protocol

protocol WidgetStateReading {
    func readWidgetState() -> WidgetTimerState?
}

struct AppGroupWidgetStateReader: WidgetStateReading {

    private let suiteName: String

    init(suiteName: String = UserDefaultKeys.appGroupSuite) {
        self.suiteName = suiteName
    }

    func readWidgetState() -> WidgetTimerState? {
        guard
            let defaults = UserDefaults(suiteName: suiteName),
            let data = defaults.data(forKey: UserDefaultKeys.widgetTimerState),
            let state = try? JSONDecoder().decode(WidgetTimerState.self, from: data)
        else { return nil }
        return state
    }
}

// MARK: -

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
    private let widgetStateReader: WidgetStateReading?

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
        alarmScheduler: AlarmScheduling? = nil,
        widgetStateReader: WidgetStateReading? = nil
    ) {
        Self.logger.notice("🛠 Initializing TimerUseCase.")

        self.timerModel = timerModel
        self.timerFactory = timerFactory
        self.nowProvider = nowProvider
        self.localNotificationManager = localNotificationManager
        self.soundPlayer = soundPlayer
        self.notificationFlagStore = notificationFlagStore
        self.alarmScheduler = alarmScheduler
        self.widgetStateReader = widgetStateReader

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
            alarmScheduler?.scheduleAlarm(remainingTime: TimeInterval(counter), timerType: timerType)
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

    /// Resets the timer to the initial state for a specific timer type.
    /// Used by App Intents that accept a "Timer Type" parameter.
    func setInitialTimerType(_ type: TimerType) {
        Self.logger.notice("🎚 Setting initial timer type to \(type.rawValue).")
        timer?.invalidate()
        alarmScheduler?.cancelAlarm()
        timerState = .initial
        timerType = type
        timerTo = 1.0
        numberOfCompletedCycles = 0
        previousPhaseWasFocus = false
        let duration = timerModel.getTime(for: type.userDefaultKey)
        counter = duration
        totalTime = duration
        totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
        onStateChange?()
    }

    /// Saves remaining time and schedules a local notification when the app enters background.
    func moveAppToBackground() {
        Self.logger.notice("👋🏻 Moving app to the background.")
        timerModel.saveBackgroundTimestamp()
        if timerState == .running {
            timerModel.saveMoveToBackgroundTime(remainingTime: counter)
            if isNotificationsEnabled {
                localNotificationManager.scheduleLocalNotification(
                    remainingTime: Double(counter),
                    timerType: timerType
                )
            }
        }
    }

    /// Cancels pending notifications and recalculates the remaining time when the app returns to foreground.
    /// If a widget interaction occurred while the app was backgrounded, applies the widget state instead
    /// of the standard elapsed-time arithmetic. If the timer expired while in background, transitions to
    /// the next phase immediately, preventing a momentary stale-state flash in the UI.
    func moveAppToForeground() {
        Self.logger.notice("👋🏻 Moving app to the foreground.")
        localNotificationManager.clearScheduledNotifications()
        let (savedRemainingTime, savedTimestampBackground) = timerModel.getSavedTimes()
        let backgroundTimestamp = timerModel.getBackgroundTimestamp()
        let hasCurrentRunningBackgroundSnapshot = isCurrentRunningBackgroundSnapshot(
            savedTimestampBackground: savedTimestampBackground,
            backgroundTimestamp: backgroundTimestamp
        )

        if timerState == .running {
            syncRunningTimerOnForeground(
                savedRemainingTime: savedRemainingTime,
                savedTimestampBackground: savedTimestampBackground,
                backgroundTimestamp: backgroundTimestamp
            )
            return
        }

        if let widgetState = widgetStateReader?.readWidgetState(),
           shouldApplyWidgetStateOnForeground(
               widgetState,
               savedRemainingTime: savedRemainingTime,
               savedTimestampBackground: savedTimestampBackground,
               backgroundTimestamp: backgroundTimestamp,
               timerWasRunningInApp: false
           ) {
            Self.logger.notice("📱 Widget changed state while app was not running — applying widget state.")
            applyWidgetState(widgetState)
            return
        }

        if hasCurrentRunningBackgroundSnapshot,
           let remainingTime = savedRemainingTime,
           let timestampBackground = savedTimestampBackground {
            applyElapsedBackgroundTime(
                remainingTime: remainingTime,
                timestampBackground: timestampBackground,
                shouldInvalidateActiveTimer: false,
                expiredLogMessage: "⏰ Restored background timer already expired — advancing phase.",
                restoreLogMessage: "⏱ Restoring running timer from saved background snapshot."
            )
        }
    }

    // MARK: - Private Methods

    private func applyWidgetState(_ widgetState: WidgetTimerState) {
        Self.logger.notice("📱 Applying widget state: \(widgetState.state).")
        timer?.invalidate()
        timer = nil
        alarmScheduler?.cancelAlarm()

        if let syncedType = TimerType(rawValue: widgetState.timerType) {
            timerType = syncedType
        }
        totalTime = max(1, widgetState.totalSeconds)
        totalNumberOfCycles = max(0, widgetState.totalCycles)
        numberOfCompletedCycles = min(
            max(0, widgetState.completedCycles),
            totalNumberOfCycles
        )

        switch widgetState.state {
        case "running":
            let newCounter = widgetState.endTime.map { max(1, Int($0.timeIntervalSinceNow)) }
                ?? widgetState.remainingSeconds
            counter = max(1, min(newCounter, totalTime))
            timerTo = CGFloat(counter) / CGFloat(totalTime)
            startTimer()
            onStateChange?()
        case "paused":
            counter = max(1, min(widgetState.remainingSeconds, totalTime))
            timerState = .paused
            timerTo = CGFloat(counter) / CGFloat(totalTime)
            onStateChange?()
        default: // "initial"
            counter = max(1, min(widgetState.remainingSeconds, totalTime))
            timerState = .initial
            timerTo = CGFloat(counter) / CGFloat(totalTime)
            onStateChange?()
        }
    }

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

private extension TimerUseCase {
    func isCurrentRunningBackgroundSnapshot(
        savedTimestampBackground: Date?,
        backgroundTimestamp: Date?
    ) -> Bool {
        guard let savedTimestampBackground, let backgroundTimestamp else { return false }
        // `saveBackgroundTimestamp()` is called first, then `saveMoveToBackgroundTime()`.
        // If saved timestamp is older than background timestamp, the saved timer data is stale.
        return savedTimestampBackground >= backgroundTimestamp
    }

    func syncRunningTimerOnForeground(
        savedRemainingTime: Int?,
        savedTimestampBackground: Date?,
        backgroundTimestamp: Date?
    ) {
        Self.logger.notice("🏃🏻‍♂️ Timer is running.")

        if let widgetState = widgetStateReader?.readWidgetState() {
            if widgetState.state == "running",
               widgetState.endTime != nil {
                Self.logger.notice("📱 Running widget countdown found — applying widget state.")
                applyWidgetState(widgetState)
                return
            }

            if shouldApplyWidgetStateOnForeground(
                widgetState,
                savedRemainingTime: savedRemainingTime,
                savedTimestampBackground: savedTimestampBackground,
                backgroundTimestamp: backgroundTimestamp,
                timerWasRunningInApp: true
            ) {
                Self.logger.notice("📱 Widget state is newer — applying widget state.")
                applyWidgetState(widgetState)
                return
            }
        }

        guard let remainingTime = savedRemainingTime,
              let timestampBackground = savedTimestampBackground else { return }

        applyElapsedBackgroundTime(
            remainingTime: remainingTime,
            timestampBackground: timestampBackground,
            shouldInvalidateActiveTimer: true,
            expiredLogMessage: "⏰ Timer expired in background — advancing phase immediately."
        )
    }

    func shouldApplyWidgetStateOnForeground(
        _ widgetState: WidgetTimerState,
        savedRemainingTime: Int?,
        savedTimestampBackground: Date?,
        backgroundTimestamp: Date?,
        timerWasRunningInApp: Bool
    ) -> Bool {
        if widgetState.state != "running" {
            guard let recencyReference = backgroundTimestamp ?? savedTimestampBackground else { return false }
            return widgetState.updatedAt > recencyReference
        }

        let widgetRemaining = widgetState.endTime.map { Int($0.timeIntervalSince(nowProvider())) }
            ?? widgetState.remainingSeconds
        guard widgetRemaining > 0 else { return false }

        if let recencyReference = savedTimestampBackground ?? backgroundTimestamp,
           widgetState.updatedAt > recencyReference {
            return true
        }

        if savedRemainingTime == nil || savedTimestampBackground == nil {
            return true
        }

        if !timerWasRunningInApp,
           let backgroundTimestamp,
           widgetState.updatedAt >= backgroundTimestamp.addingTimeInterval(-2) {
            return true
        }

        return false
    }

    func applyElapsedBackgroundTime(
        remainingTime: Int,
        timestampBackground: Date,
        shouldInvalidateActiveTimer: Bool,
        expiredLogMessage: String,
        restoreLogMessage: String? = nil
    ) {
        let timeInBackground = Int(DateInterval(start: timestampBackground, end: nowProvider()).duration)
        let totalRemainingTime = remainingTime - timeInBackground

        if totalRemainingTime <= 0 {
            Self.logger.notice("\(expiredLogMessage)")
            if shouldInvalidateActiveTimer {
                timer?.invalidate()
                timer = nil
            }
            changeTimerMode()
            if isAutoStartEnabled {
                startTimer()
            }
        } else {
            if let restoreLogMessage {
                Self.logger.notice("\(restoreLogMessage)")
            }
            counter = totalRemainingTime; startTimer()
        }
        onStateChange?()
    }
}
