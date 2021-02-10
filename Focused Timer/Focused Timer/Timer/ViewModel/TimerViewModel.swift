//
//  TimerViewModel.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 01/10/20.
//

import SwiftUI

class TimerViewModel: ObservableObject {

    // MARK: - Published Variables
    @Published var focusedTime: Int
    @Published var timerState: TimerState = .initial
    @Published var to: CGFloat = 1
    @Published var count: Int
    @Published var countTime: String
    @Published var timerType: TimerType = .focused

    // MARK: - Private Variables
    private var timer = Timer()
    private let timerModel: TimerModelProtocol
    private let dateFormatter = DateComponentsFormatter()

    // MARK: - Initializer

    init(timerModel: TimerModelProtocol) {

        self.dateFormatter.allowedUnits = [.minute, .second]
        self.dateFormatter.zeroFormattingBehavior = .pad
        self.dateFormatter.unitsStyle = .positional

        self.timerModel = timerModel
        self.focusedTime = timerModel.getFocusedTime()
        self.count = timerModel.getFocusedTime()

        self.countTime = self.dateFormatter.string(from: TimeInterval(timerModel.getFocusedTime())) ?? "-"
    }

    // MARK: - Public Methods
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.count <= self.focusedTime && self.count != 0 {
                self.timerState = .running
                self.count -= 1
                withAnimation(.default) {
                    self.to = CGFloat(self.count) / CGFloat(self.focusedTime)
                }
                self.countTime = self.dateFormatter.string(from: TimeInterval(self.count)) ?? "-"
            }
            else {
                self.to = 1
                self.count = self.focusedTime
                self.timerState = .initial
                self.countTime = self.dateFormatter.string(from: TimeInterval(self.timerModel.getFocusedTime())) ?? "-"

                self.timerType = self.timerType == .focused ? .rest : .focused

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
        count = timerModel.getFocusedTime()
        timer.invalidate()
        focusedTime = timerModel.getFocusedTime()
        timerType = .focused
        countTime = dateFormatter.string(from: TimeInterval(timerModel.getFocusedTime())) ?? "-"
    }
}
