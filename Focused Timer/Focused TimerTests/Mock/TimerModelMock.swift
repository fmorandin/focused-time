//
//  TimerModelMock.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
@testable import Focused_Timer

struct TimerModelMock: TimerModelProtocol {
    func getFocusedTime() -> Int {
        5
    }
}
