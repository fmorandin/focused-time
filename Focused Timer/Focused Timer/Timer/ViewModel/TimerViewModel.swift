//
//  TimerViewModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 01/10/20.
//

import AVFoundation
import SwiftUI
import os

protocol RepeatingTimerProtocol: AnyObject {
    func invalidate()
}

protocol RepeatingTimerFactoryProtocol {
    func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping (RepeatingTimerProtocol) -> Void
    ) -> RepeatingTimerProtocol
}

private final class FoundationRepeatingTimer: RepeatingTimerProtocol {
    private var timer: Timer?

    init(timer: Timer) {
        self.timer = timer
    }

    func invalidate() {
        timer?.invalidate()
    }
}

struct FoundationRepeatingTimerFactory: RepeatingTimerFactoryProtocol {
    func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping (RepeatingTimerProtocol) -> Void
    ) -> RepeatingTimerProtocol {
        var wrappedTimer: FoundationRepeatingTimer?
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { _ in
            guard let wrappedTimer else { return }
            block(wrappedTimer)
        }

        let createdTimer = FoundationRepeatingTimer(timer: timer)
        wrappedTimer = createdTimer
        return createdTimer
    }
}

final class TimerViewModel: ObservableObject {

    // MARK: - Published Variables

    @Published var totalTime: Int
    @Published var timerState: TimerState = .initial
    @Published var timerTo: CGFloat = 1
    @Published var counter: Int
    @Published var countTime: String
    @Published var timerType: TimerType = .focused
    @Published var totalNumberOfCycles: Int
    @Published var numberOfCompletedCycles: Int
    @Published var accentCircleColor: Color

    // MARK: - Public Variables

    var primaryButtonImageName: String {
        switch timerState {
        case .running:
            return ImageNames.pause
        case .paused, .initial:
            return ImageNames.play
        }
    }

    var primaryButtonText: LocalizedStringKey {
        switch timerState {
        case .running:
            return Translation.pauseTimer
        case .paused:
            return Translation.resumeTimer
        case .initial:
            return Translation.playTimer
        }
    }

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TimerViewModel.self)
    )

    private var timer: RepeatingTimerProtocol?
    private let timerFactory: RepeatingTimerFactoryProtocol
    private let timerModel: TimerModelProtocol
    private let dateFormatter = DateComponentsFormatter()
    private let localNotificationManager = LocalNotificationManager()
    private let nowProvider: () -> Date
    private var isAutoStartEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.autoStartToggle)
    }
    private var isPlaySoundEnabled: Bool {
        timerModel.getToggle(for: UserDefaultKeys.playTimerSounds)
    }
    private var keepScreenOn: Bool {
        timerModel.getToggle(for: UserDefaultKeys.keepScreenOn)
    }

    // Create the sound id that will be played when the timer finishes
    private let systemSoundID: SystemSoundID = 1009

    // MARK: - Initializer

    init(
        timerModel: TimerModelProtocol,
        timerFactory: RepeatingTimerFactoryProtocol = FoundationRepeatingTimerFactory(),
        nowProvider: @escaping () -> Date = Date.init
    ) {

        Self.logger.notice("🛠 Initializing Timer View Model.")

        dateFormatter.allowedUnits = [.minute, .second]
        dateFormatter.zeroFormattingBehavior = .pad
        dateFormatter.unitsStyle = .positional

        self.timerModel = timerModel
        self.timerFactory = timerFactory
        self.nowProvider = nowProvider

        /// The initial state for the app will be the focused time
        let savedFocusedTimer = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        totalTime = savedFocusedTimer
        counter = savedFocusedTimer

        countTime = self.dateFormatter.string(from: TimeInterval(savedFocusedTimer)) ?? "-"

        totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
        numberOfCompletedCycles = 0

        accentCircleColor = .focusColor
    }

    // MARK: - Public Methods

    /// Function that handles all the events when the timer is running.
    /// This one also does the logic between the timer types and what to do on any of the them.
    func startTimer() {

        Self.logger.notice("▶️ Starting timer.")
        timer = timerFactory.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] scheduledTimer in
            guard let self else { return }

            if self.counter <= self.totalTime && self.counter != 0 {
                self.updateTimerRunning()
            } else {
                self.changeTimerMode()

                if self.isAutoStartEnabled {
                    self.startTimer()
                }

                scheduledTimer.invalidate()
            }
        }
    }

    /// This simply sets the state and invalidate the timer so it won't will be running during the pause
    func pauseTimer() {

        Self.logger.notice("⏸ Pausing timer.")
        timerState = .paused
        timer?.invalidate()
    }

    /// This is responsible to set all the properties to their initial state again.
    /// The initial state of the app will always be the focused time.
    func resetUpdateTimer() {

        Self.logger.notice("🔄 Resetting timer.")
        timerState = .initial
        timerTo = 1
        counter = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        totalTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        timerType = .focused
        countTime = dateFormatter.string(
            from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"
        timer?.invalidate()
        totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
        numberOfCompletedCycles = 0
        accentCircleColor = .focusColor
    }

    /// Method that handles the necessary actions for when the app is moved to the background
    /// In this case, once the app is moved to background a notification will be schedule and
    /// the remaining time will be saved on UserDefaults
    /// Besides the remaining time, the now timestamp will be saved as well in order to calculate
    /// how long the app stand on the background
    func moveAppToBackground() {

        Self.logger.notice("👋🏻 Moving app to the background.")
        if timerState == .running {
            /// The biggest part of what is described above will be handled by the model
            timerModel.saveMoveToBackgroundTime(remainingTime: counter)

            // Schedule a notification so user would know when the timer finishes
            localNotificationManager.scheduleLocalNotification(remainingTime: Double(counter))
        }
    }

    /// Method that handles the necessary actions for when the app is moved to the foreground
    /// In this case, once de app is moved to foreground any pending notification
    /// will be canceled, the saved values will be read
    /// and the calculation will be done in order to update the timer
    func moveAppToForeground() {

        Self.logger.notice("👋🏻 Moving app to the foreground.")
        // Cancel any scheduled/already sent notifications
        localNotificationManager.clearScheduledNotifications()

        if timerState == .running {
            Self.logger.notice("🏃🏻‍♂️ Timer is running.")
            // Recover the saved values and to the math to update the remaining time
            let (savedRemainingTime, savedTimestampBackground) = timerModel.getSavedTimes()

            guard let remainingTime = savedRemainingTime,
                  let timestampBackground = savedTimestampBackground else { return }

            let timeInBackground = Int(DateInterval(start: timestampBackground, end: nowProvider()).duration)

            let totalRemainingTime = remainingTime - timeInBackground
            counter = totalRemainingTime <= 0 ? 0 : totalRemainingTime
        }
    }

    func shouldDisplaySettingsAlert() -> Bool {

        timerState == .running || timerState == .paused ? true : false
    }

    func shouldKeepScreenOn() -> Bool {

        keepScreenOn
    }

    // MARK: - Fileprivate

    /// This one is responsible to do the necessary updates for when the
    /// timer is running, independently from the timer type.
    fileprivate func updateTimerRunning() {

        Self.logger.notice("⏲ Setting timer to running, decreasing counter and formatting count time.")
        timerState = .running
        counter -= 1
        withAnimation(.default) {
            timerTo = CGFloat(counter) / CGFloat(totalTime)
        }
        countTime = dateFormatter.string(from: TimeInterval(counter)) ?? "-"
    }

    /// This is the function that is called when a timer finishes.
    /// Essentially it will do two things: Increase the necessary variables that handles
    /// the cycles and decide what timer should go next
    fileprivate func changeTimerMode() {

        Self.logger.notice("🆕 Changing Timer mode.")

        // If the user don't check the option to play sounds
        // or if they came from a notification, the sound shouldn't be played
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotification) {
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.isNotification)
        } else {
            if isPlaySoundEnabled {
                // to play sound
                AudioServicesPlaySystemSound(systemSoundID)
            }
        }

        timerTo = 1
        timerState = .initial

        handleCompletedCycle()

        if numberOfCompletedCycles == totalNumberOfCycles {
            Self.logger.notice("🥳 Completed the number of cycles.")
            changeTimerType(timerType: .longBreak)
        } else {
            if timerType == .focused {
                Self.logger.notice("🤓 Focused Timer.")
                changeTimerType(timerType: .focused)
            } else {
                Self.logger.notice("😮‍💨 Short Break.")
                changeTimerType(timerType: .shortBreak)
            }
        }
    }

    /// Auxiliary function to keep tracking of the number of completed cycles.
    fileprivate func handleCompletedCycle() {

        if timerType == .focused {
            Self.logger.notice("👏🏻 Cycle completed.")
            numberOfCompletedCycles += 1
        } else if timerType == .longBreak {
            Self.logger.notice("💪🏻 Long break done.")
            numberOfCompletedCycles = 0
        }
    }

    /// This is responsible to check the timer type and do the necessary update on the
    /// variables based on the type.
    /// - Parameter timerType: the type of the timer that was running
    fileprivate func changeTimerType(timerType: TimerType) {

        Self.logger.notice("🔃 Time to change the mode.")
        switch timerType {
        case .focused:
            Self.logger.notice("🔃 Changing from focused to short break.")
            self.timerType = .shortBreak
            counter = timerModel.getTime(for: UserDefaultKeys.shortBreakTime)
            totalTime = timerModel.getTime(for: UserDefaultKeys.shortBreakTime)
            countTime = dateFormatter
                .string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.shortBreakTime))) ?? "-"
            accentCircleColor = .shortBreakColor

        case .shortBreak:
            Self.logger.notice("🔃 Changing from short break to focused.")
            self.timerType = .focused
            counter = timerModel.getTime(for: UserDefaultKeys.focusedTime)
            totalTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
            countTime = dateFormatter
                .string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"
            accentCircleColor = .focusColor

        case .longBreak:
            Self.logger.notice("🔃 Changing to long break.")
            self.timerType = .longBreak
            counter = timerModel.getTime(for: UserDefaultKeys.longBreakTime)
            totalTime = timerModel.getTime(for: UserDefaultKeys.longBreakTime)
            countTime = dateFormatter
                .string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.longBreakTime))) ?? "-"
            accentCircleColor = .longBreakColor
        }
    }
}
