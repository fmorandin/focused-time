//
//  WhatsNewUITests.swift
//  Focused TimerUITests
//

import XCTest

/// Default launch: the modal must stay suppressed, since `setUp()` wipes
/// UserDefaults on every run and a naive flag would re-trigger it here.
final class WhatsNewUITests: BaseFeature, @unchecked Sendable {

    func test_WhatsNewDoesNotAppearByDefault() {
        // GIVEN the app launches under normal UI-testing conditions

        // THEN the What's New modal never appears
        let dismissButton = application.buttons[Accessibility.Identifiers.btnWhatsNewDismiss]
        XCTAssertFalse(dismissButton.waitForExistence(timeout: 3), "What's New should stay suppressed by default")
    }
}

/// Opts into forcing the modal via the `UI-Testing-WhatsNew` launch argument,
/// the deliberate escape hatch for exercising the feature end to end.
final class WhatsNewForcedUITests: BaseFeature, @unchecked Sendable {

    override var extraLaunchArguments: [String] { ["UI-Testing-WhatsNew"] }

    func test_WhatsNewAppearsWhenForced() {
        // GIVEN the app is launched with the forced-presentation argument

        // THEN the modal is visible with its title and dismiss button
        let title = application.staticTexts[Accessibility.Identifiers.lblWhatsNewTitle]
        XCTAssertTrue(title.waitForExistence(timeout: 5))

        let dismissButton = application.buttons[Accessibility.Identifiers.btnWhatsNewDismiss]
        XCTAssertTrue(dismissButton.exists)
    }

    func test_DismissClosesTheModal() {
        // GIVEN the modal is visible
        let dismissButton = application.buttons[Accessibility.Identifiers.btnWhatsNewDismiss]
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 5))

        // WHEN I tap the dismiss button
        dismissButton.tap()

        // THEN the modal is no longer on screen and the timer tab is usable
        XCTAssertFalse(dismissButton.exists)
        let playPauseButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }

    func test_SeeAllChangesOpensTheFullChangelog() {
        // GIVEN the modal is visible
        let seeAllButton = application.buttons[Accessibility.Identifiers.btnWhatsNewSeeAll]
        XCTAssertTrue(seeAllButton.waitForExistence(timeout: 5))

        // WHEN I tap "See all changes"
        seeAllButton.tap()

        // THEN the modal closes and the full changelog is shown in Settings
        let release = application.staticTexts[Accessibility.Identifiers.lblChangelogRelease].firstMatch
        XCTAssertTrue(release.waitForExistence(timeout: 5))

        let dismissButton = application.buttons[Accessibility.Identifiers.btnWhatsNewDismiss]
        XCTAssertFalse(dismissButton.exists)
    }
}
