//
//  TimerModelMock.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
@testable import Focused_Timer

struct TimerModelMock: TimerModelProtocol {
    var startingTimerType: TimerType = .focused

    func getStartingTimerType() -> TimerType {
        startingTimerType
    }

    func getToggle(for keyName: String) -> Bool {
        switch keyName {
        case "keepScreenOn":
            return true
        case "autoStart":
            return false
        case "playSounds":
            return false
        default:
            return false
        }
    }

    func getNumberOfCycles(for keyName: String) -> String {
        "2"
    }

    func getSavedTimes() -> (Int?, Date?) {
        return (nil, nil)
    }

    func getSavedBackgroundTimerState() -> BackgroundTimerState? {
        return nil
    }

    func clearSavedBackgroundState() {}

    func saveMoveToBackgroundTime(
        remainingTime: Int,
        timerType: TimerType,
        numberOfCompletedCycles: Int,
        previousPhaseWasFocus: Bool
    ) {}

    func getTime(for keyName: String) -> Int {
        switch keyName {
        case "focusedTime":
            return 5
        case "shortBreakTime":
            return 2
        case "longBreakTime":
            return 3
        default:
            return 1
        }
    }
}
