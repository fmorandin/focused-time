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

    private let defaults = UserDefaults.standard

    private var timer = Timer()
    @Published var timerState: TimerState = .initial
    @Published var to: CGFloat = 0
    @Published var count = 0

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.count != self.getTotalTime() {
                self.timerState = .running
                self.count += 1
                withAnimation(.default) {
                    self.to = CGFloat(self.count) / CGFloat(self.getTotalTime())
                }
            }
            else {
                self.to = 0
                self.count = 0
                self.timerState = .initial
                timer.invalidate()
            }
        })
    }

    func pauseTimer() {
        timerState = .paused
        timer.invalidate()
    }

    func resetTimer() {
        timerState = .initial
        to = 0
        count = 0
        timer.invalidate()
    }

    func getTotalTime() -> Int {
        defaults.integer(forKey: "totalTime")
    }
}
