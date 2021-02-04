//
//  SettingsModelMock.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
@testable import Focused_Timer

struct SettingsModelMock: SettingsModelProtocol {
    func saveFocusedTime(time: Int) {
        print("Saved")
    }

    func getFocusedTime() -> Int {
        5
    }
}
