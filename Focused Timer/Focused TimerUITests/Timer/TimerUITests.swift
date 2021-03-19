//
//  TimerUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import XCTest

class TimerUITests: BaseFeature {

    func test_TimerStartedCorrectly()  throws {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons[Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts[Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, "01:00")

        let lblCycleCounter = app.staticTexts[Identifiers.lblCycleCounter]
        XCTAssertEqual(lblCycleCounter.label, "0/4")

        // WHEN I click to start the timer
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expected = expectation(description: "Timer Running")
        let result = XCTWaiter.wait(for: [expected], timeout: 5.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:55")
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func test_TimerResumedCorrectly() throws {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons[Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts[Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, "01:00")

        let lblCycleCounter = app.staticTexts[Identifiers.lblCycleCounter]
        XCTAssertEqual(lblCycleCounter.label, "0/4")

        // WHEN I click to start the timer
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedRunning = expectation(description: "Timer Running")
        let result = XCTWaiter.wait(for: [expectedRunning], timeout: 5.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:55")
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the play/pause button again
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedPaused = expectation(description: "Timer Paused")
        let resultPause = XCTWaiter.wait(for: [expectedPaused], timeout: 5.0)
        if resultPause == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Play")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:55")
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the play/pause button again
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedResumed = expectation(description: "Timer Resumed")
        let resultResumed = XCTWaiter.wait(for: [expectedResumed], timeout: 5.0)
        if resultResumed == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:50")
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func test_TimerResettedCorrectly() throws {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons[Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts[Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, "01:00")

        let lblCycleCounter = app.staticTexts[Identifiers.lblCycleCounter]
        XCTAssertEqual(lblCycleCounter.label, "0/4")

        // WHEN I click to start the timer
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedRunning = expectation(description: "Timer Running")
        let result = XCTWaiter.wait(for: [expectedRunning], timeout: 5.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:55")
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the play/pause button again
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedPaused = expectation(description: "Timer Paused")
        let resultPause = XCTWaiter.wait(for: [expectedPaused], timeout: 5.0)
        if resultPause == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Play")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:55")
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I click on the reset
        let resetButton = app.buttons[Identifiers.btnResetIdentifier]
        XCTAssertEqual(resetButton.label, "Reset cycle")
        resetButton.tap()

        // This is used to let the screen reacts to the tap
        let expectedResetted = expectation(description: "Timer Resumed")
        let resultResetted = XCTWaiter.wait(for: [expectedResetted], timeout: 5.0)
        if resultResetted == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Play"
            XCTAssertEqual(playButton.label, "Play")

            // AND the counter should be resetted
            XCTAssertEqual(lblCounter.label, "01:00")
        } else {
            XCTFail("Delay interrupted")
        }
    }

    #warning("Find a better way to implement this")
    func test_ChangeModesAutomatically() {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons[Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts[Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, "01:00")

        let lblCycleCounter = app.staticTexts[Identifiers.lblCycleCounter]
        XCTAssertEqual(lblCycleCounter.label, "0/4")

        let circleFocused = app.otherElements[Identifiers.circleFocused]
        XCTAssertTrue(circleFocused.exists)

        // WHEN I start the focused timer
        playButton.tap()

        // AND I wait the time so the app will change modes automatically
        // This is used to let the screen reacts to the tap
        let expectedFocused = expectation(description: "Focused Timer")
        let resultFocused = XCTWaiter.wait(for: [expectedFocused], timeout: 61.0)
        if resultFocused == XCTWaiter.Result.timedOut {
            // THEN the mode will be changed to rest
            let circleRest = app.otherElements[Identifiers.circleRest]
            XCTAssertTrue(circleRest.exists)

            let playButtonRest = app.buttons[Identifiers.btnStartPauseIdentifier]
            XCTAssertEqual(playButtonRest.label, "Play")

            let lblCounterRest = app.staticTexts[Identifiers.lblCounter]
            XCTAssertEqual(lblCounterRest.label, "01:00")
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I start the rest timer
        playButton.tap()

        // AND I wait the time so the app will change modes automatically
        // This is used to let the screen reacts to the tap
        let expectedRest = expectation(description: "Resting Timer")
        let resultRest = XCTWaiter.wait(for: [expectedRest], timeout: 61.0)
        if resultRest == XCTWaiter.Result.timedOut {
            // THEN the mode will be changed to rest
            let circleFocused = app.otherElements[Identifiers.circleFocused]
            XCTAssertTrue(circleFocused.exists)

            let playButtonRest = app.buttons[Identifiers.btnStartPauseIdentifier]
            XCTAssertEqual(playButtonRest.label, "Play")

            let lblCounterRest = app.staticTexts[Identifiers.lblCounter]
            XCTAssertEqual(lblCounterRest.label, "01:00")

            let lblCycleCounter = app.staticTexts[Identifiers.lblCycleCounter]
            XCTAssertEqual(lblCycleCounter.label, "1/4")
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func test_MoveAppToBackgroundAndBackToForeground() {
        // GIVEN I have the screen on its initial state
        let playButton = app.buttons[Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblCounter = app.staticTexts[Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, "01:00")

        // WHEN I start the timer
        playButton.tap()

        // AND I wait 5 seconds
        // This is used to let the screen reacts to the tap
        let expected = expectation(description: "Timer Running")
        let result = XCTWaiter.wait(for: [expected], timeout: 5.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:55")
        } else {
            XCTFail("Delay interrupted")
        }

        // WHEN I move the app to background
        XCUIDevice.shared.press(.home)

        // AND I wait 10 seconds
        // This is used to let the screen reacts to the tap
        let expectedAfterResume = expectation(description: "Timer Running")
        let resultAfterResume = XCTWaiter.wait(for: [expectedAfterResume], timeout: 10.0)
        if resultAfterResume == XCTWaiter.Result.timedOut {

            // AND
            app.activate()

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the counter should be updated
            XCTAssertEqual(lblCounter.label, "00:45")
        } else {
            XCTFail("Delay interrupted")
        }
    }

}
