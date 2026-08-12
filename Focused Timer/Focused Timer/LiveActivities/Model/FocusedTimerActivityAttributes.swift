//
//  FocusedTimerActivityAttributes.swift
//  Focused Timer
//

import ActivityKit
import Foundation

enum TimerActivityPhase: String, Codable, Hashable, Sendable {
    case focused
    case shortBreak
    case longBreak
}

enum TimerActivityStatus: String, Codable, Hashable, Sendable {
    case running
    case paused
    case completed
}

struct FocusedTimerActivityAttributes: ActivityAttributes {

    struct ContentState: Codable, Hashable, Sendable {
        let phase: TimerActivityPhase
        let status: TimerActivityStatus
        let timerStartDate: Date
        let timerEndDate: Date
        let pauseDate: Date?
        let completedCycles: Int
        let totalCycles: Int
        let completionDate: Date?

        var timerRange: ClosedRange<Date> {
            timerStartDate...max(timerStartDate, timerEndDate)
        }

        func remainingTime(at date: Date) -> TimeInterval {
            guard status != .completed else { return 0 }
            let effectiveDate = status == .paused ? pauseDate ?? date : date
            return max(0, timerEndDate.timeIntervalSince(effectiveDate))
        }

        func progress(at date: Date) -> Double {
            let duration = timerEndDate.timeIntervalSince(timerStartDate)
            guard duration > 0 else { return 0 }
            return min(1, max(0, remainingTime(at: date) / duration))
        }

        func completed(at date: Date) -> Self {
            Self(
                phase: phase,
                status: .completed,
                timerStartDate: timerStartDate,
                timerEndDate: timerEndDate,
                pauseDate: nil,
                completedCycles: completedCycles,
                totalCycles: totalCycles,
                completionDate: date
            )
        }
    }

    let identifier: UUID
}
