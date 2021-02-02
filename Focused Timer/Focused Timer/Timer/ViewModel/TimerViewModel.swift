//
//  TimerViewModel.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 01/10/20.
//

import Foundation
import SwiftUI
import Combine

class TimerViewModel: ObservableObject {

    // MARK: - Published Variables
    @Published var totalTime: Int
    @Published var timerState: TimerState = .initial
    @Published var to: CGFloat = 1
    @Published var count: Int
    @Published var countTime: String

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
        self.totalTime = timerModel.getTotalTime()
        self.count = timerModel.getTotalTime()

        self.countTime = self.dateFormatter.string(from: TimeInterval(timerModel.getTotalTime())) ?? "-"
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
                self.to = 1
                self.count = self.totalTime
                self.timerState = .initial
                self.countTime = self.dateFormatter.string(from: TimeInterval(self.timerModel.getTotalTime())) ?? "-"
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
        count = timerModel.getTotalTime()
        timer.invalidate()
        totalTime = timerModel.getTotalTime()
        countTime = dateFormatter.string(from: TimeInterval(timerModel.getTotalTime())) ?? "-"
    }
}
