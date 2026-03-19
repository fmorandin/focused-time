//
//  MockTimerService.swift
//  Focused TimerTests
//
//  Test double for TimerServiceProtocol used by App Intent tests.
//

import Foundation
@testable import Focused_Timer

final class MockTimerService: TimerServiceProtocol, @unchecked Sendable {

    let timerViewModel: TimerViewModel

    init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel
    }
}
