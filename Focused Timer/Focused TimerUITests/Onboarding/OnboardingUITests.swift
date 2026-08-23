//
//  OnboardingUITests.swift
//  Focused TimerUITests
//

import XCTest

final class OnboardingUITests: BaseFeature, @unchecked Sendable {

    func test_OnboardingDoesNotAppearByDefault() {
        let getStartedButton = application.buttons[Accessibility.Identifiers.btnOnboardingGetStarted]
        XCTAssertFalse(getStartedButton.waitForExistence(timeout: 3))
    }
}

final class OnboardingForcedUITests: BaseFeature, @unchecked Sendable {

    override var extraLaunchArguments: [String] { ["UI-Testing-Onboarding"] }

    func test_OnboardingAppearsWithoutWhatsNew() {
        let title = application.staticTexts[Accessibility.Identifiers.lblOnboardingTitle]
        XCTAssertTrue(title.waitForExistence(timeout: 5))

        let whatsNewButton = application.buttons[Accessibility.Identifiers.btnWhatsNewDismiss]
        XCTAssertFalse(whatsNewButton.exists)
    }

    func test_GetStartedClosesOnboarding() {
        let getStartedButton = application.buttons[Accessibility.Identifiers.btnOnboardingGetStarted]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 5))

        getStartedButton.tap()

        XCTAssertFalse(getStartedButton.exists)
        let playPauseButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertTrue(playPauseButton.waitForExistence(timeout: 5))
    }
}
