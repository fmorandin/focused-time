//
//  Focused_TimerUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import XCTest

class Focused_TimerUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        app.launch()
    }

    override func tearDown() {
        app.terminate()
    }

    func test_TimerStartedCorrectly() {
        let expected = expectation(description: "Timer Running")

        // WHEN I click to start the timer
        let playButton = app.buttons["btnStartPauseIdentifier"]
        XCTAssertEqual(playButton.label, "Play")
        playButton.tap()

        // This is used to let the screen reacts to the tap
        let result = XCTWaiter.wait(for: [expected], timeout: 2.0)
        if result == XCTWaiter.Result.timedOut {

            // THEN the button label should be changed to "Pause"
            XCTAssertEqual(playButton.label, "Pause")

            // AND the circle should start to be filled
            #warning("Add this scenario")
        } else {
            XCTFail("Delay interrupted")
        }
    }
}
