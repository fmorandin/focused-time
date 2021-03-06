//
//  TimerViewModel.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 01/10/20.
//

import SwiftUI
import AVFoundation

class TimerViewModel: ObservableObject {

    // MARK: - Published Variables
    @Published var totalTime: Int
    @Published var timerState: TimerState = .initial
    @Published var to: CGFloat = 1
    @Published var count: Int
    @Published var countTime: String
    @Published var timerType: TimerType = .focused

    // MARK: - Private Variables
    private var timer = Timer()
    private let timerModel: TimerModelProtocol
    private let dateFormatter = DateComponentsFormatter()

    // create a sound ID
    private let systemSoundID: SystemSoundID = 1009

    // MARK: - Initializer

    init(timerModel: TimerModelProtocol) {

        self.dateFormatter.allowedUnits = [.minute, .second]
        self.dateFormatter.zeroFormattingBehavior = .pad
        self.dateFormatter.unitsStyle = .positional

        self.timerModel = timerModel

        /// The initial state for the app will be the focused time
        self.totalTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        self.count = timerModel.getTime(for: UserDefaultKeys.focusedTime)

        self.countTime = self.dateFormatter.string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"
    }

    // MARK: - Public Methods
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.count <= self.totalTime && self.count != 0 {
                self.timerState = .running
                self.count -= 1
                withAnimation(.default) {
                    self.to = CGFloat(self.count) / CGFloat(self.totalTime)
                }
                self.countTime = self.dateFormatter.string(from: TimeInterval(self.count)) ?? "-"
            }
            else {
                // to play sound
                AudioServicesPlaySystemSound (self.systemSoundID)
                self.to = 1
                self.timerState = .initial

                if self.timerType == .focused {
                    self.timerType = .rest
                    self.count = self.timerModel.getTime(for: UserDefaultKeys.restTime)
                    self.totalTime = self.timerModel.getTime(for: UserDefaultKeys.restTime)
                    self.countTime = self.dateFormatter.string(from: TimeInterval(self.timerModel.getTime(for: UserDefaultKeys.restTime))) ?? "-"
                } else {
                    self.timerType = .focused
                    self.count = self.timerModel.getTime(for: UserDefaultKeys.focusedTime)
                    self.totalTime = self.timerModel.getTime(for: UserDefaultKeys.focusedTime)
                    self.countTime = self.dateFormatter.string(from: TimeInterval(self.timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"
                }

                timer.invalidate()
            }
        })
    }

    func pauseTimer() {
        timerState = .paused
        timer.invalidate()
    }

    func resetUpdateTimer() {
        timerState = .initial
        to = 1
        count = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        totalTime = timerModel.getTime(for: UserDefaultKeys.focusedTime)
        timerType = .focused
        countTime = dateFormatter.string(from: TimeInterval(timerModel.getTime(for: UserDefaultKeys.focusedTime))) ?? "-"
        timer.invalidate()
    }


    /// Method that handles the necessary actions for when the app is moved to the background
    /// In this case, once the app is moved to background a notification will be schedule and the remaining time will be saved on UserDefaults
    /// Besides the remaining time, the now timestamp will be saved as well in order to calculate how long the app stand on the background
    func moveAppToBackground() {
        /// The biggest part of what is described above will be handled by the model
        timerModel.saveMoveToBackgroundTime(remainingTime: count)
    }

    /// Method that handles the necessary actions for when the app is moved to the foreground
    /// In this case, once de app is moved to foreground any pending notification will be canceled, the saved values will be read
    /// and the calculation will be done in order to update the timer
    func moveAppToForeground() {
        let (savedRemainingTime, savedTimestampBackground) = timerModel.getSavedTimes()

        guard let remainingTime = savedRemainingTime,
              let timestampBackground = savedTimestampBackground else { return }

        let timeInBackground = Int(DateInterval(start: timestampBackground, end: Date()).duration)

        let totalRemainingTime = remainingTime - timeInBackground
        count = totalRemainingTime <= 0 ? 0 : totalRemainingTime

    }

    // MARK: - Private Functions

}
