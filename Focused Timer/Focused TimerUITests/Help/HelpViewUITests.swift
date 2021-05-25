//
//  HelpViewUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 26/03/21.
//

import XCTest

final class HelpViewUITests: BaseFeature {

    func test_HelpScreenLoadedCorrectly() {
        // WHEN I open the help page
        let showHelpButton = app.buttons[Accessibility.Identifiers.btnShowHelp]
        showHelpButton.tap()

        // THEN All the elements should load correctly
        let techniqueExplanationTitle = app.staticTexts[Accessibility.Identifiers.lblTechniqueExplanationTitle]
        XCTAssert(techniqueExplanationTitle.exists, "The technique explanation title should be present")

        let techniqueExplanation = app.staticTexts[Accessibility.Identifiers.lblTechniqueExplanation]
        XCTAssert(techniqueExplanation.exists, "The technique explanation should be present")

        let focusExplanationTitle = app.staticTexts[Accessibility.Identifiers.lblFocusExplanationTitle]
        XCTAssert(focusExplanationTitle.exists, "The focus explanation title should be present")

        let focusExplanation = app.staticTexts[Accessibility.Identifiers.lblFocusExplanation]
        XCTAssert(focusExplanation.exists, "The focus explanation should be present")

        let shortBreakExplanationTitle = app.staticTexts[Accessibility.Identifiers.lblShortBreakExplanationTitle]
        XCTAssert(shortBreakExplanationTitle.exists, "The shortBreak explanation title should be present")

        let shortBreakExplanation = app.staticTexts[Accessibility.Identifiers.lblShortBreakExplanation]
        XCTAssert(shortBreakExplanation.exists, "The shortBreak explanation should be present")

        let longBreakExplanationTitle = app.staticTexts[Accessibility.Identifiers.lblLongBreakExplanationTitle]
        XCTAssert(longBreakExplanationTitle.exists, "The long break explanation title should be present")

        let longBreakExplanation = app.staticTexts[Accessibility.Identifiers.lblLongBreakExplanation]
        XCTAssert(longBreakExplanation.exists, "The long break explanation should be present")

        let numberOfCyclesExplanationTitle = app.staticTexts[
            Accessibility.Identifiers.lblNumberOfCyclesExplanationTitle
        ]
        XCTAssert(numberOfCyclesExplanationTitle.exists, "The number of cycles explanation should be present")

        let numberOfCyclesExplanation = app.staticTexts[Accessibility.Identifiers.lblNumberOfCyclesExplanation]
        XCTAssert(numberOfCyclesExplanation.exists, "The number of cycles explanation should be present")
    }
}
