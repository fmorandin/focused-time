//
//  ChangelogUITests.swift
//  Focused TimerUITests
//

import XCTest

final class ChangelogUITests: BaseFeature, @unchecked Sendable {

    /// The changelog row sits near the bottom of the Settings form, below the fold on most
    /// devices, so it must be scrolled into view before it can be tapped.
    private func scrollToChangelogRowIfNeeded(maxSwipes: Int = 3) -> XCUIElement {
        let changelogRow = application.buttons[Accessibility.Identifiers.btnSettingsChangelog]
        guard !(changelogRow.exists && changelogRow.isHittable) else { return changelogRow }

        for _ in 0..<maxSwipes {
            application.swipeUp()
            if changelogRow.exists && changelogRow.isHittable { return changelogRow }
        }

        return changelogRow
    }

    func test_ChangelogRowOpensFullHistory() {
        // GIVEN I open Settings
        application.tabBars.firstMatch.buttons["Settings"].tap()

        // WHEN I tap the What's New row
        let changelogRow = scrollToChangelogRowIfNeeded()
        XCTAssertTrue(changelogRow.waitForExistence(timeout: 5))
        changelogRow.tap()

        // THEN the full changelog is shown, with at least one release
        let release = application.staticTexts[Accessibility.Identifiers.lblChangelogRelease].firstMatch
        XCTAssertTrue(release.waitForExistence(timeout: 5))
    }

    func test_BackButtonReturnsToSettings() {
        // GIVEN the full changelog is open
        application.tabBars.firstMatch.buttons["Settings"].tap()
        let changelogRow = scrollToChangelogRowIfNeeded()
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
