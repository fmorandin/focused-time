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
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.totalNumberOfCycles, "4")

        // WHEN I start the timer
        timerViewModel.startTimer()

        // THEN the timer state should be running
        let result = XCTWaiter.wait(for: [expected], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(timerViewModel.timerState, TimerState.running)
            XCTAssertNotEqual(timerViewModel.counter, 0)
            XCTAssertNotEqual(timerViewModel.timerTo, 0)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN the timer ends
        let finalExpectation = expectation(description: "Timer finished")
        let finalResult = XCTWaiter.wait(for: [finalExpectation], timeout: 5.0)
        if finalResult == XCTWaiter.Result.timedOut {

            // THEN the values should be changed for the rest time
            XCTAssertEqual(timerViewModel.timerState, TimerState.initial)
            XCTAssertEqual(timerViewModel.counter, 2)
            XCTAssertEqual(timerViewModel.timerTo, 1.0)
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
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.totalNumberOfCycles, "4")

        // WHEN I start the timer
        timerViewModel.startTimer()

        // THEN the timer state should be running
        let result = XCTWaiter.wait(for: [expected], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(timerViewModel.timerState, TimerState.running)
            XCTAssertNotEqual(timerViewModel.counter, 0)
            XCTAssertNotEqual(timerViewModel.timerTo, 0)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I reset the timer
        timerViewModel.resetUpdateTimer()

        // THEN the status should be updated back to initial
        XCTAssertEqual(timerViewModel.timerState, TimerState.initial)

        // AND the related fields should be reseted
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
    }

    func test_CompleteFlow() throws {
        let expected = expectation(description: "Timer Running")

        // AND the timer state is .initial
        XCTAssertEqual(timerViewModel.timerState, TimerState.initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.totalNumberOfCycles, "4")

        // WHEN I start the timer
        timerViewModel.startTimer()

        // THEN the timer state should be running
        let result = XCTWaiter.wait(for: [expected], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(timerViewModel.timerState, TimerState.running)
            XCTAssertNotEqual(timerViewModel.counter, 0)
            XCTAssertNotEqual(timerViewModel.timerTo, 0)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN the timer ends
        let finalFocusedExpectation = expectation(description: "Timer finished")
        let finalFocusedResult = XCTWaiter.wait(for: [finalFocusedExpectation], timeout: 5.0)
        if finalFocusedResult == XCTWaiter.Result.timedOut {

            // THEN the values should be changed for the rest time
            XCTAssertEqual(timerViewModel.timerState, TimerState.initial)
            XCTAssertEqual(timerViewModel.counter, 2)
            XCTAssertEqual(timerViewModel.timerTo, 1.0)
            XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        }

        // WHEN I start the timer
        timerViewModel.startTimer()

        // WHEN the timer ends
        let finalRestExpectation = expectation(description: "Timer finished")
        let finalRestResult = XCTWaiter.wait(for: [finalRestExpectation], timeout: 5.0)
        if finalRestResult == XCTWaiter.Result.timedOut {

            // THEN the values should be changed for the focused time
            XCTAssertEqual(timerViewModel.timerState, TimerState.initial)
            XCTAssertEqual(timerViewModel.counter, 5)
            XCTAssertEqual(timerViewModel.timerTo, 1.0)
            XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)
        }
    }

}
