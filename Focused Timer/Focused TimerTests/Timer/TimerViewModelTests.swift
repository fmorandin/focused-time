//
//  TimerViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import XCTest
@testable import Focused_Timer

class TimerViewModelTests: XCTestCase {

    private let timerViewModel = TimerViewModel(timerModel: TimerModelMock())

    func test_StartTimer() throws {
        let expected = expectation(description: "Timer Running")

        // AND the timer state is .initial
        XCTAssertEqual(timerViewModel.timerState, TimerState.initial)
        XCTAssertEqual(timerViewModel.count, 5)
        XCTAssertEqual(timerViewModel.to, 1.0)

        // WHEN I start the timer
        timerViewModel.startTimer()

        // THEN the timer state should be running
        let result = XCTWaiter.wait(for: [expected], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(timerViewModel.timerState, TimerState.running)
            XCTAssertNotEqual(timerViewModel.count, 0)
            XCTAssertNotEqual(timerViewModel.to, 0)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN the timer ends
        let finalExpectation = expectation(description: "Timer finished")
        let finalResult = XCTWaiter.wait(for: [finalExpectation], timeout: 5.0)
        if finalResult == XCTWaiter.Result.timedOut {

            // THEN the values should be reseted
            XCTAssertEqual(timerViewModel.timerState, TimerState.initial)
            XCTAssertEqual(timerViewModel.count, 5)
            XCTAssertEqual(timerViewModel.to, 1.0)
        }
    }

    func test_PauseTimer() throws {
        let expected = expectation(description: "Timer Running")

        // AND the timer state is .initial
        XCTAssertEqual(timerViewModel.timerState, TimerState.initial)

        // WHEN I start the timer
        timerViewModel.startTimer()

        // THEN the timer state should be running
        _ = XCTWaiter.wait(for: [expected], timeout: 1.0)

        // WHEN I pause the timer
        timerViewModel.pauseTimer()

        // THEN the status should be updated
        XCTAssertEqual(timerViewModel.timerState, TimerState.paused)
    }

    func test_ResetTimer() throws {
        let expected = expectation(description: "Timer Running")

        // AND the timer state is .initial
        XCTAssertEqual(timerViewModel.timerState, TimerState.initial)
        XCTAssertEqual(timerViewModel.count, 5)
        XCTAssertEqual(timerViewModel.to, 1.0)

        // WHEN I start the timer
        timerViewModel.startTimer()

        // THEN the timer state should be running
        let result = XCTWaiter.wait(for: [expected], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(timerViewModel.timerState, TimerState.running)
            XCTAssertNotEqual(timerViewModel.count, 0)
            XCTAssertNotEqual(timerViewModel.to, 0)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I reset the timer
        timerViewModel.resetUpdateTimer()

        // THEN the status should be updated back to initial
        XCTAssertEqual(timerViewModel.timerState, TimerState.initial)

        // AND the related fields should be reseted
        XCTAssertEqual(timerViewModel.count, 5)
        XCTAssertEqual(timerViewModel.to, 1.0)
    }

}
