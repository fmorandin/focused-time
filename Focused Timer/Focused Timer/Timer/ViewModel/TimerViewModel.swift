//
//  TimerViewModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 01/10/20.
//

import SwiftUI
import AVFoundation

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

    // MARK: - Private Variables

    private var timer = Timer()
    private let timerModel: TimerModelProtocol
    private let dateFormatter = DateComponentsFormatter()
    private let localNotificationManager = LocalNotificationManager()
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

    init(timerModel: TimerModelProtocol) {

        self.dateFormatter.allowedUnits = [.minute, .second]
        self.dateFormatter.zeroFormattingBehavior = .pad
        self.dateFormatter.unitsStyle = .positional

        self.timerModel = timerModel

        /// The initial state for the app will be the focused time
        self.totalTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        self.counter = timerModel.getTime(for: UserDefaultKeys.focusedTime)

        self.countTime = self.dateFormatter.string(
            from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"

        self.totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
        self.numberOfCompletedCycles = 0

        self.accentCircleColor = .orange
    }

    // MARK: - Public Methods

    /// Function that handles all the events when the timer is running.
    /// This one also does the logic between the timer types and what to do on any of the them.
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.counter <= self.totalTime && self.counter != 0 {
                self.updateTimerRunning()
            } else {
                self.changeTimerMode()

                if self.isAutoStartEnabled {
                    self.startTimer()
                }

                timer.invalidate()
            }
        })
    }

    /// This simply sets the state and invalidate the timer so it won't will be running during the pause
    func pauseTimer() {
        timerState = .paused
        timer.invalidate()
    }

    /// This is responsible to set all the properties to their initial state again.
    /// The initial state of the app will always be the focused time.
    func resetUpdateTimer() {
        timerState = .initial
        timerTo = 1
        counter = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        totalTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        timerType = .focused
        countTime = dateFormatter.string(
            from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"
        timer.invalidate()
        totalNumberOfCycles = Int(timerModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
        numberOfCompletedCycles = 0
        accentCircleColor = .orange
    }

    /// Method that handles the necessary actions for when the app is moved to the background
    /// In this case, once the app is moved to background a notification will be schedule and
    /// the remaining time will be saved on UserDefaults
    /// Besides the remaining time, the now timestamp will be saved as well in order to calculate
    /// how long the app stand on the background
    func moveAppToBackground() {
        if timerState == .running {
            /// The biggest part of what is described above will be handled by the model
            timerModel.saveMoveToBackgroundTime(remainingTime: counter)

            // Schedule a notification so user would know when the timer finishes
            localNotificationManager.schedule(remainingTime: Double(counter))
        }
    }

    /// Method that handles the necessary actions for when the app is moved to the foreground
    /// In this case, once de app is moved to foreground any pending notification
    /// will be canceled, the saved values will be read
    /// and the calculation will be done in order to update the timer
    func moveAppToForeground() {
        // Cancel any scheduled/already sent notifications
        localNotificationManager.clearScheduledNotifications()

        if timerState == .running {
            // Recover the saved values and to the math to update the remaining time
            let (savedRemainingTime, savedTimestampBackground) = timerModel.getSavedTimes()

            guard let remainingTime = savedRemainingTime,
                  let timestampBackground = savedTimestampBackground else { return }

            let timeInBackground = Int(DateInterval(start: timestampBackground, end: Date()).duration)

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
        self.timerState = .running
        self.counter -= 1
        withAnimation(.default) {
            self.timerTo = CGFloat(self.counter) / CGFloat(self.totalTime)
        }
        self.countTime = self.dateFormatter.string(from: TimeInterval(self.counter)) ?? "-"
    }

    /// This is the function that is called when a timer finishes.
    /// Essentially it will do two things: Increase the necessary variables that handles
    /// the cycles and decide what timer should go next
    func changeTimerMode() {

        // If the user don't check the option to play sounds
        // or if they came from a notification, the sound shouldn't be played
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotification) {
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.isNotification)
        } else {
            if isPlaySoundEnabled {
                // to play sound
                AudioServicesPlaySystemSound(self.systemSoundID)
            }
        }

        self.timerTo = 1
        self.timerState = .initial

        handleCompletedCycle()

        if self.numberOfCompletedCycles == self.totalNumberOfCycles {
            changeTimerType(timerType: .longBreak)
        } else {
            if self.timerType == .focused {
                changeTimerType(timerType: .focused)
            } else {
                changeTimerType(timerType: .shortBreak)
            }
        }
    }

    /// Auxiliary function to keep tracking of the number of completed cycles.
    fileprivate func handleCompletedCycle() {
        if timerType == .focused {
            numberOfCompletedCycles += 1
        } else if timerType == .longBreak {
            numberOfCompletedCycles = 0
        }
    }

    /// This is responsible to check the timer type and do the necessary update on the
    /// variables based on the type.
    /// - Parameter timerType: the type of the timer that was running
    fileprivate func changeTimerType(timerType: TimerType) {
        switch timerType {
        case .focused:
            self.timerType = .shortBreak
            counter = timerModel.getTime(for: UserDefaultKeys.shortBreakTime)
            totalTime = timerModel.getTime(for: UserDefaultKeys.shortBreakTime)
            countTime = dateFormatter
                .string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.shortBreakTime))) ?? "-"
            accentCircleColor = .blue

        case .shortBreak:
            self.timerType = .focused
            counter = timerModel.getTime(for: UserDefaultKeys.focusedTime)
            totalTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
            countTime = dateFormatter
                .string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"
            accentCircleColor = .orange

        case .longBreak:
            self.timerType = .longBreak
            counter = timerModel.getTime(for: UserDefaultKeys.longBreakTime)
            totalTime = timerModel.getTime(for: UserDefaultKeys.longBreakTime)
            countTime = dateFormatter
                .string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.longBreakTime))) ?? "-"
            accentCircleColor = .green
        }
    }
}
