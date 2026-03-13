//
//  HelpViewUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 26/03/21.
//

import XCTest

final class HelpViewUITests: BaseFeature, @unchecked Sendable {

    func test_HelpScreenLoadedCorrectly() {
        // WHEN I open the help tab
        application.tabBars.firstMatch.buttons["Help"].tap()

        // THEN All the content elements should load correctly
        let techniqueExplanation = application.staticTexts[Accessibility.Identifiers.lblTechniqueExplanation]
        XCTAssert(techniqueExplanation.exists, "The technique explanation should be present")

        let focusExplanation = application.staticTexts[Accessibility.Identifiers.lblFocusExplanation]
        XCTAssert(focusExplanation.exists, "The focus explanation should be present")

        let shortBreakExplanation = application.staticTexts[Accessibility.Identifiers.lblShortBreakExplanation]
        XCTAssert(shortBreakExplanation.exists, "The shortBreak explanation should be present")

        application.swipeUp()

        let longBreakExplanation = application.staticTexts[Accessibility.Identifiers.lblLongBreakExplanation]
        XCTAssert(longBreakExplanation.exists, "The long break explanation should be present")

        let numberOfCyclesExplanation = application.staticTexts[Accessibility.Identifiers.lblNumberOfCyclesExplanation]
        XCTAssert(numberOfCyclesExplanation.exists, "The number of cycles explanation should be present")
    }

    func test_HelpTabCanBeSwitchedAway() {
        // GIVEN the help tab is open
        application.tabBars.firstMatch.buttons["Help"].tap()

        let techniqueExplanation = application.staticTexts[Accessibility.Identifiers.lblTechniqueExplanation]
        XCTAssertTrue(techniqueExplanation.exists, "Help screen should be displayed after opening")

        // WHEN I switch back to the timer tab
        application.tabBars.firstMatch.buttons["Timer"].tap()

        // THEN the main timer screen should be accessible again and help content gone
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertTrue(
            waitForExistence(playButton),
            "Timer start button should be visible after switching away from help"
        )
        XCTAssertFalse(techniqueExplanation.exists, "Help content should no longer be visible")
    }
}
