//
//  ChangelogUITests.swift
//  Focused TimerUITests
//

import XCTest

final class ChangelogUITests: BaseFeature, @unchecked Sendable {

    func test_ChangelogRowOpensFullHistory() {
        // GIVEN I open Settings
        application.tabBars.firstMatch.buttons["Settings"].tap()

        // WHEN I tap the What's New row
        let changelogRow = application.buttons[Accessibility.Identifiers.btnSettingsChangelog]
        XCTAssertTrue(changelogRow.waitForExistence(timeout: 5))
        changelogRow.tap()

        // THEN the full changelog is shown, with at least one release
        let release = application.staticTexts[Accessibility.Identifiers.lblChangelogRelease].firstMatch
        XCTAssertTrue(release.waitForExistence(timeout: 5))
    }

    func test_BackButtonReturnsToSettings() {
        // GIVEN the full changelog is open
        application.tabBars.firstMatch.buttons["Settings"].tap()
        let changelogRow = application.buttons[Accessibility.Identifiers.btnSettingsChangelog]
        XCTAssertTrue(changelogRow.waitForExistence(timeout: 5))
        changelogRow.tap()

        let release = application.staticTexts[Accessibility.Identifiers.lblChangelogRelease].firstMatch
        XCTAssertTrue(release.waitForExistence(timeout: 5))

        // WHEN I navigate back
        application.navigationBars.buttons.firstMatch.tap()

        // THEN the Settings row is visible again
        XCTAssertTrue(changelogRow.waitForExistence(timeout: 5))
    }
}
