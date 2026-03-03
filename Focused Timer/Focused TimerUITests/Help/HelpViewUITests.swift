//
//  HelpViewUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 26/03/21.
//

import XCTest

final class HelpViewUITests: BaseFeature, @unchecked Sendable {

    func test_HelpScreenLoadedCorrectly() {
        // WHEN I open the help page
        let showHelpButton = application.buttons[Accessibility.Identifiers.btnShowHelp]
        showHelpButton.tap()

        // THEN All the elements should load correctly
        let techniqueExplanationTitle = application.staticTexts[Accessibility.Identifiers.lblTechniqueExplanationTitle]
        XCTAssert(techniqueExplanationTitle.exists, "The technique explanation title should be present")

        let techniqueExplanation = application.staticTexts[Accessibility.Identifiers.lblTechniqueExplanation]
        XCTAssert(techniqueExplanation.exists, "The technique explanation should be present")

        let focusExplanationTitle = application.staticTexts[Accessibility.Identifiers.lblFocusExplanationTitle]
        XCTAssert(focusExplanationTitle.exists, "The focus explanation title should be present")

        let focusExplanation = application.staticTexts[Accessibility.Identifiers.lblFocusExplanation]
        XCTAssert(focusExplanation.exists, "The focus explanation should be present")

        let shortBreakExplanationTitle = application.staticTexts[
            Accessibility.Identifiers.lblShortBreakExplanationTitle
        ]
        XCTAssert(shortBreakExplanationTitle.exists, "The shortBreak explanation title should be present")

        let shortBreakExplanation = application.staticTexts[Accessibility.Identifiers.lblShortBreakExplanation]
        XCTAssert(shortBreakExplanation.exists, "The shortBreak explanation should be present")

        let longBreakExplanationTitle = application.staticTexts[Accessibility.Identifiers.lblLongBreakExplanationTitle]
        XCTAssert(longBreakExplanationTitle.exists, "The long break explanation title should be present")

        let longBreakExplanation = application.staticTexts[Accessibility.Identifiers.lblLongBreakExplanation]
        XCTAssert(longBreakExplanation.exists, "The long break explanation should be present")

        let numberOfCyclesExplanationTitle = application.staticTexts[
            Accessibility.Identifiers.lblNumberOfCyclesExplanationTitle
        ]
        XCTAssert(numberOfCyclesExplanationTitle.exists, "The number of cycles explanation should be present")

        let numberOfCyclesExplanation = application.staticTexts[Accessibility.Identifiers.lblNumberOfCyclesExplanation]
        XCTAssert(numberOfCyclesExplanation.exists, "The number of cycles explanation should be present")
    }

    func test_HelpScreenCanBeDismissed() {
        // GIVEN the help screen is open
        application.buttons[Accessibility.Identifiers.btnShowHelp].tap()

        let techniqueExplanationTitle = application.staticTexts[Accessibility.Identifiers.lblTechniqueExplanationTitle]
        XCTAssertTrue(techniqueExplanationTitle.exists, "Help screen should be displayed after opening")

        // WHEN I tap the close button
        application.buttons[Accessibility.Identifiers.btnCloseModal].tap()

        // THEN the main timer screen should be accessible again and help content gone
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertTrue(waitForExistence(playButton), "Timer start button should be visible after dismissing help")
        XCTAssertFalse(techniqueExplanationTitle.exists, "Help content should no longer be visible")
    }
}
