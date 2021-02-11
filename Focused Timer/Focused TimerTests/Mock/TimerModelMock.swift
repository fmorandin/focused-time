//
//  TimerModelMock.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
@testable import Focused_Timer

struct TimerModelMock: TimerModelProtocol {
    func getTime(for key: String) -> Int {
        switch key {
        case "focusedTime":
            return 5
        case "restTime":
            return 2
        default:
            return 1
        }
    }
}
