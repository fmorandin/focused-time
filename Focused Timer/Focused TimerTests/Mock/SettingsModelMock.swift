//
//  SettingsModelMock.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
@testable import Focused_Timer

struct SettingsModelMock: SettingsModelProtocol {

    func saveTime(time: Int, for key: String) {
        debugPrint("⏱ saved")
    }

    func getTime(for key: String) -> Int {
        switch key {
        case "focusedTime":
            return 1500
        case "restTime":
            return 300
        case "longBreak":
            return 1800
        default:
            return 10
        }
    }

    func saveCycleTotal(cycleNumber: Int, for keyName: String) {
        debugPrint("↻ number of cycles saved")
    }

    func getCycleTotal(for keyName: String) -> String {
        return "10"
    }
}
