//
//  TimerUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 28/09/20.
//

import XCTest

final class TimerUITests: BaseFeature {

    private let initialCounterLabel = "00:05"

    func test_TimerStartedCorrectly() {
        let playButton = app.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = app.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(lblTimerType.label, "Focus")

        let lblCounter = app.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, initialCounterLabel)

        let lblCycleCounter = app.staticTexts[Accessibility.Identifiers.lblCycleCounter]
        XCTAssertEqual(lblCycleCounter.label, "0/4")

        playButton.tap()

        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))
        XCTAssertTrue(waitForLabel(lblCounter, notEquals: initialCounterLabel, timeout: 2.0))
        XCTAssertEqual(lblTimerType.label, "Focus")
    }

    func test_TimerResumedCorrectly() {
        let playButton = app.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = app.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(lblTimerType.label, "Focus")

        let lblCounter = app.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))
        XCTAssertTrue(waitForLabel(lblCounter, notEquals: initialCounterLabel, timeout: 2.0))

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Resume", timeout: 2.0))

        let pausedCounter = lblCounter.label

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))
        XCTAssertTrue(waitForLabel(lblCounter, notEquals: pausedCounter, timeout: 2.0))

        XCTAssertEqual(lblTimerType.label, "Focus")
    }

    func test_TimerResettedCorrectly() {
        let playButton = app.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = app.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(lblTimerType.label, "Focus")

        let lblCounter = app.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Resume", timeout: 2.0))

        let resetButton = app.buttons[Accessibility.Identifiers.btnResetIdentifier]
        XCTAssertEqual(resetButton.label, "Reset")
        resetButton.tap()

        XCTAssertTrue(waitForLabel(playButton, equals: "Play", timeout: 2.0))
        XCTAssertEqual(lblTimerType.label, "Focus")
        XCTAssertEqual(lblCounter.label, initialCounterLabel)
    }

    func test_ChangeModesAutomatically() {
        let playButton = app.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = app.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(lblTimerType.label, "Focus")

        let lblCounter = app.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, initialCounterLabel)

        let lblCycleCounter = app.staticTexts[Accessibility.Identifiers.lblCycleCounter]
        XCTAssertEqual(lblCycleCounter.label, "0/4")

        let circleFocused = app.otherElements[Accessibility.Identifiers.circleFocused]
        XCTAssertTrue(circleFocused.exists)

        playButton.tap()
        XCTAssertTrue(waitForLabel(lblTimerType, equals: "Short Break", timeout: 8.0))

        let circleBreak = app.otherElements[Accessibility.Identifiers.circleBreak]
        XCTAssertTrue(circleBreak.exists)
        XCTAssertEqual(playButton.label, "Play")
        XCTAssertEqual(lblCounter.label, initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(lblTimerType, equals: "Focus", timeout: 8.0))

        XCTAssertTrue(circleFocused.exists)
        XCTAssertEqual(playButton.label, "Play")
        XCTAssertEqual(lblCounter.label, initialCounterLabel)
        XCTAssertEqual(lblCycleCounter.label, "1/4")
    }

    func test_MoveAppToBackgroundAndBackToForeground() {
        let playButton = app.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = app.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(lblTimerType.label, "Focus")

        let lblCounter = app.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))
        XCTAssertTrue(waitForLabel(lblCounter, notEquals: initialCounterLabel, timeout: 2.0))

        let counterBeforeBackground = lblCounter.label

        XCUIDevice.shared.press(.home)
        _ = XCTWaiter.wait(for: [expectation(description: "background delay")], timeout: 2.0)
        app.activate()

        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))
        XCTAssertEqual(lblTimerType.label, "Focus")
        XCTAssertTrue(waitForLabel(lblCounter, notEquals: counterBeforeBackground, timeout: 2.0))
    }

    // swiftlint:disable force_cast
    func test_TestAutoStart() {
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        let autoStartToggle = app.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertEqual(autoStartToggle.value as! String, "0")
        autoStartToggle.switches.firstMatch.tap()
        XCTAssertEqual(autoStartToggle.value as! String, "1")

        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        let playButton = app.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = app.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(lblTimerType.label, "Focus")

        let lblCounter = app.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(lblCounter.label, initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(lblTimerType, equals: "Short Break", timeout: 8.0))
        XCTAssertTrue(waitForLabel(playButton, notEquals: "Play", timeout: 3.0))

        // Auto start should run short break automatically, then return to focus.
        XCTAssertTrue(waitForLabel(lblTimerType, equals: "Focus", timeout: 8.0))

        let circleFocused = app.otherElements[Accessibility.Identifiers.circleFocused]
        XCTAssertTrue(circleFocused.exists)
        XCTAssertTrue(waitForLabel(playButton, notEquals: "Play", timeout: 3.0))
        XCTAssertTrue(waitForLabel(lblCounter, notEquals: initialCounterLabel, timeout: 3.0))
    }
    // swiftlint:enable force_cast
}
