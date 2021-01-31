//
//  TimerUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import XCTest

class TimerUITests: BaseFeature {

    func test_TimerStartedCorrectly() {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons["btnStartPauseIdentifier"]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts["lblCounter"]
        XCTAssertEqual(lblCounter.label, "0 of 5")

        let uiExternalCircle = app.otherElements["uiExternalCircle"]
        XCTAssertEqual(uiExternalCircle.frame.width, 300)

        // WHEN I click to start the timer
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expected = expectation(description: "Timer Running")
        let result = XCTWaiter.wait(for: [expected], timeout: 2.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "2 of 5")

            // AND the circle should start to be filled
            XCTAssertNotEqual(uiExternalCircle.frame.width, 300)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func test_TimerResumedCorrectly() {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons["btnStartPauseIdentifier"]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts["lblCounter"]
        XCTAssertEqual(lblCounter.label, "0 of 5")

        let uiExternalCircle = app.otherElements["uiExternalCircle"]
        XCTAssertEqual(uiExternalCircle.frame.width, 300)

        // WHEN I click to start the timer
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedRunning = expectation(description: "Timer Running")
        let result = XCTWaiter.wait(for: [expectedRunning], timeout: 2.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "2 of 5")

            // AND the circle should start to be filled
            XCTAssertNotEqual(uiExternalCircle.frame.width, 300)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the play/pause button again
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedPaused = expectation(description: "Timer Paused")
        let resultPause = XCTWaiter.wait(for: [expectedPaused], timeout: 2.0)
        if resultPause == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Play")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "2 of 5")

            // AND the circle should start to be filled
            XCTAssertNotEqual(uiExternalCircle.frame.width, 300)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the play/pause button again
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedResumed = expectation(description: "Timer Resumed")
        let resultResumed = XCTWaiter.wait(for: [expectedResumed], timeout: 2.0)
        if resultResumed == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "4 of 5")

            // AND the circle should start to be filled
            XCTAssertNotEqual(uiExternalCircle.frame.width, 300)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func test_TimerResettedCorrectly() {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons["btnStartPauseIdentifier"]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts["lblCounter"]
        XCTAssertEqual(lblCounter.label, "0 of 5")

        let uiExternalCircle = app.otherElements["uiExternalCircle"]
        XCTAssertEqual(uiExternalCircle.frame.width, 300)

        // WHEN I click to start the timer
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedRunning = expectation(description: "Timer Running")
        let result = XCTWaiter.wait(for: [expectedRunning], timeout: 2.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "2 of 5")

            // AND the circle should start to be filled
            XCTAssertNotEqual(uiExternalCircle.frame.width, 300)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the play/pause button again
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedPaused = expectation(description: "Timer Paused")
        let resultPause = XCTWaiter.wait(for: [expectedPaused], timeout: 2.0)
        if resultPause == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Play")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "2 of 5")

            // AND the circle should start to be filled
            XCTAssertNotEqual(uiExternalCircle.frame.width, 300)
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the reset
        let resetButton = app.buttons["btnResetIdentifier"]
        XCTAssertEqual(resetButton.label, "Reset")
        resetButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedResetted = expectation(description: "Timer Resumed")
        let resultResetted = XCTWaiter.wait(for: [expectedResetted], timeout: 2.0)
        if resultResetted == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Play")

            // AND the counter should be resetted
            XCTAssertEqual(lblCounter.label, "0 of 5")

            // AND the circle should be resetted
            XCTAssertEqual(uiExternalCircle.frame.width, 300)
        } else {
            XCTFail("Delay interrupted")
        }
    }
}
