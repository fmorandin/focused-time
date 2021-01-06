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
        // WHEN I click to start the timer
        let playButton = app.buttons["btnStartPauseIdentifier"]
        XCTAssertEqual(playButton.label, "Play")
        playButton.tap()

        sleep(1)

        // THEN the button label should be changed to "Pause"
        XCTAssertEqual(playButton.label, "Pause")

        // AND the circle should start to be filled
        #warning("Add this scenario")
    }
}
