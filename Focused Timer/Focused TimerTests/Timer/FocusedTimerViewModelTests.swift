//
//  FocusedTimerControllerTests.swift
//  Focused TimerTests
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import XCTest
@testable import Focused_Timer

class FocusedTimerViewModelTests: XCTestCase {

    func test_StartTimer() {
        // GIVEN I have the timerController
        let timerController = TimerViewModel()
        let expected = expectation(description: "Timer Running")

        // AND the timer state is .initial
        XCTAssertEqual(timerController.timerState, TimerState.initial)
        XCTAssertEqual(timerController.count, 0)
        XCTAssertEqual(timerController.to, 0)

        // WHEN I start the timer
        timerController.startTimer()

        // THEN the timer state should be running
        let result = XCTWaiter.wait(for: [expected], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(timerController.timerState, TimerState.running)
            XCTAssertNotEqual(timerController.count, 0)
            XCTAssertNotEqual(timerController.to, 0)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN the timer ends
        let finalExpectation = expectation(description: "Timer finished")
        let finalResult = XCTWaiter.wait(for: [finalExpectation], timeout: 5.0)
        if finalResult == XCTWaiter.Result.timedOut {

            // THEN the values should be reseted
            XCTAssertEqual(timerController.timerState, TimerState.initial)
            XCTAssertEqual(timerController.count, 0)
            XCTAssertEqual(timerController.to, 0)
        }
    }

    func test_PauseTimer() {
        // GIVEN I have the timerController
        let timerController = TimerViewModel()
        let expected = expectation(description: "Timer Running")

        // AND the timer state is .initial
        XCTAssertEqual(timerController.timerState, TimerState.initial)

        // WHEN I start the timer
        timerController.startTimer()

        // THEN the timer state should be running
        _ = XCTWaiter.wait(for: [expected], timeout: 1.0)

        // WHEN I pause the timer
        timerController.pauseTimer()

        // THEN the status should be updated
        XCTAssertEqual(timerController.timerState, TimerState.paused)
    }

    func test_ResetTimer() {
        // GIVEN I have the timerController
        let timerController = TimerViewModel()
        let expected = expectation(description: "Timer Running")

        // AND the timer state is .initial
        XCTAssertEqual(timerController.timerState, TimerState.initial)
        XCTAssertEqual(timerController.count, 0)
        XCTAssertEqual(timerController.to, 0)

        // WHEN I start the timer
        timerController.startTimer()

        // THEN the timer state should be running
        let result = XCTWaiter.wait(for: [expected], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(timerController.timerState, TimerState.running)
            XCTAssertNotEqual(timerController.count, 0)
            XCTAssertNotEqual(timerController.to, 0)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I reset the timer
        timerController.resetTimer()

        // THEN the status should be updated back to initial
        XCTAssertEqual(timerController.timerState, TimerState.initial)

        // AND the related fields should be reseted
        XCTAssertEqual(timerController.count, 0)
        XCTAssertEqual(timerController.to, 0)
    }

}
