//
//  SettingsModelMock.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
@testable import Focused_Timer

struct SettingsModelMock: SettingsModelProtocol {
    func saveToggle(value: Bool, for keyName: String) {
        debugPrint("🎛 toggle saved")
    }

    func getToggle(for keyName: String) -> Bool {
        switch keyName {
        case "screenOn":
            return true
        case "autoStart":
            return false
        case "playSounds":
            return false
        default:
            return false
        }
    }

    func saveTime(time: Int, for key: String) {
        debugPrint("⏱ saved")
    }

    func getTime(for key: String) -> Int {
        switch key {
        case "focusedTime":
            return 1500
        case "shortBreakTime":
            return 300
        case "longBreak":
            return 1800
        default:
            return 10
        }
    }

    func saveNumberOfCycles(numberOfCycles: Int, for keyName: String) {
        debugPrint("↻ number of cycles saved")
    }

    func getNumberOfCycles(for keyName: String) -> String {
        return "10"
    }
}
