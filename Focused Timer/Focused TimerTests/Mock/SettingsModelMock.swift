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
        print("Saved")
    }

    func getTime(for key: String) -> Int {
        switch key {
        case "focusedTime":
            return 1500
        case "restTime":
            return 300
        default:
            return 10
        }
    }
}
