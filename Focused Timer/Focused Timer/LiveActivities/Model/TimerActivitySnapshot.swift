//
//  TimerActivitySnapshot.swift
//  Focused Timer
//

import Foundation

struct TimerActivitySnapshot: Equatable, Sendable {
    let phase: TimerActivityPhase
    let status: TimerActivityStatus
    let totalTime: Int
    let remainingTime: Int
    let completedCycles: Int
    let totalCycles: Int
    let capturedAt: Date

    var contentState: FocusedTimerActivityAttributes.ContentState {
        let elapsedTime = max(0, totalTime - remainingTime)
        return FocusedTimerActivityAttributes.ContentState(
            phase: phase,
            status: status,
            timerStartDate: capturedAt.addingTimeInterval(-TimeInterval(elapsedTime)),
            timerEndDate: capturedAt.addingTimeInterval(TimeInterval(max(0, remainingTime))),
            pauseDate: status == .paused ? capturedAt : nil,
            completedCycles: completedCycles,
            totalCycles: totalCycles,
            completionDate: nil
        )
    }
}

extension TimerActivityPhase {
    init(timerType: TimerType) {
        switch timerType {
        case .focused:
            self = .focused
        case .shortBreak:
            self = .shortBreak
        case .longBreak:
            self = .longBreak
        }
    }
}
