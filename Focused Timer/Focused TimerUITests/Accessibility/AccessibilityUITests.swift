//
//  AccessibilityUITests.swift
//  Focused TimerUITests
//

import XCTest

final class AccessibilityUITests: BaseFeature, @unchecked Sendable {

    private let semanticAuditTypes: XCUIAccessibilityAuditType = [
        .elementDetection,
        .hitRegion,
        .sufficientElementDescription,
        .trait
    ]

    func test_CommonScreensPassSemanticAccessibilityAudit() throws {
        try application.performAccessibilityAudit(for: semanticAuditTypes)

        application.tabBars.firstMatch.buttons["Settings"].tap()
        XCTAssertTrue(application.navigationBars["Settings"].waitForExistence(timeout: 5))
        try application.performAccessibilityAudit(for: semanticAuditTypes)

        application.tabBars.firstMatch.buttons["Help"].tap()
        let explanation = application.staticTexts[Accessibility.Identifiers.lblTechniqueExplanation]
        XCTAssertTrue(explanation.waitForExistence(timeout: 5))
        try application.performAccessibilityAudit(for: semanticAuditTypes)
    }

    func test_TimerExposesMeaningfulLabelsAndValues() {
        let timerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(timerType.label, "Current timer")
        XCTAssertEqual(String(describing: timerType.value!), "Focus")

        let countdown = application.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(countdown.label, "Time remaining")
        XCTAssertEqual(String(describing: countdown.value!), "00:05")

        let cycles = application.staticTexts[Accessibility.Identifiers.lblCycleCounter]
        XCTAssertEqual(cycles.label, "Cycles completed")
        XCTAssertEqual(String(describing: cycles.value!), "0 of 4")
    }

    func test_InvalidSettingHasVisibleAndAccessibleExplanation() {
        application.tabBars.firstMatch.buttons["Settings"].tap()

        let field = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(XCUIKeyboardKey.delete.rawValue)

        let error = application.staticTexts[Accessibility.Identifiers.lblInvalidNumberMessage].firstMatch
        XCTAssertTrue(error.waitForExistence(timeout: 5))
        XCTAssertEqual(error.label, "Enter a number to save this setting.")
        XCTAssertEqual(String(describing: field.value!), "Invalid value")
    }
}

final class WhatsNewAccessibilityUITests: BaseFeature, @unchecked Sendable {

    override var extraLaunchArguments: [String] { ["UI-Testing-WhatsNew"] }

    func test_WhatsNewPassesAccessibilityAudit() throws {
        let title = application.staticTexts[Accessibility.Identifiers.lblWhatsNewTitle]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        let semanticAuditTypes: XCUIAccessibilityAuditType = [
            .elementDetection,
            .hitRegion,
            .sufficientElementDescription,
            .trait
        ]
        try application.performAccessibilityAudit(for: semanticAuditTypes)
    }
}
