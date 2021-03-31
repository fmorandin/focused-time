//
//  TimerModelMock.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
@testable import Focused_Timer

struct TimerModelMock: TimerModelProtocol {
    func getToggle(for keyName: String) -> Bool {
        switch keyName {
        case "screenOn":
            return false
        case "autoStart":
            return false
        default:
            return false
        }
    }

    func getNumberOfCycles(for keyName: String) -> String {
        "2"
    }

    func getSavedTimes() -> (Int?, Date?) {
        return (0, Date())
    }

    func saveMoveToBackgroundTime(remainingTime: Int) {}

    func getTime(for key: String) -> Int {
        switch key {
        case "focusedTime":
            return 5
        case "restTime":
            return 2
        case "longBreak":
            return 3
        default:
            return 1
        }
    }
}
