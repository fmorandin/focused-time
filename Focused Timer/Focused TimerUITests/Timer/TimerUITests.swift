//
//  TimerUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 28/09/20.
//

import XCTest

final class TimerUITests: BaseFeature, @unchecked Sendable {

    private let initialCounterLabel = "00:05"

    func test_TimerStartedCorrectly() {
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")

        let lblCounter = application.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)

        let lblCycleCounter = application.staticTexts[Accessibility.Identifiers.lblCycleCounter]
        XCTAssertEqual(String(describing: lblCycleCounter.value!), "0 of 4")

        playButton.tap()

        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))
        XCTAssertTrue(waitForValue(lblCounter, notEquals: initialCounterLabel, timeout: 2.0))
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")
    }

    func test_TimerResumedCorrectly() {
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")

        let lblCounter = application.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 4.0))
        XCTAssertTrue(waitForValue(lblCounter, notEquals: initialCounterLabel, timeout: 4.0))

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Resume", timeout: 4.0))

        let pausedCounter = String(describing: lblCounter.value!)

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 4.0))
        XCTAssertTrue(waitForValue(lblCounter, notEquals: pausedCounter, timeout: 4.0))

        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")
    }

    func test_TimerResettedCorrectly() {
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")

        let lblCounter = application.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Resume", timeout: 2.0))

        let resetButton = application.buttons[Accessibility.Identifiers.btnResetIdentifier]
        XCTAssertEqual(resetButton.label, "Reset")
        resetButton.tap()

        XCTAssertTrue(waitForLabel(playButton, equals: "Play", timeout: 2.0))
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)
    }

    func test_ChangeModesAutomatically() {
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")

        let lblCounter = application.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)

        let lblCycleCounter = application.staticTexts[Accessibility.Identifiers.lblCycleCounter]
        XCTAssertEqual(String(describing: lblCycleCounter.value!), "0 of 4")

        playButton.tap()
        XCTAssertTrue(waitForValue(lblTimerType, equals: "Short Break", timeout: 8.0))

        XCTAssertEqual(playButton.label, "Play")
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForValue(lblTimerType, equals: "Focus", timeout: 8.0))

        XCTAssertEqual(playButton.label, "Play")
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)
        XCTAssertEqual(String(describing: lblCycleCounter.value!), "1 of 4")
    }

    func test_MoveAppToBackgroundAndBackToForeground() {
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")

        let lblCounter = application.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))
        XCTAssertTrue(waitForValue(lblCounter, notEquals: initialCounterLabel, timeout: 2.0))

        let counterBeforeBackground = String(describing: lblCounter.value!)

        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 2.0)
        application.activate()

        if waitForLabel(playButton, equals: "Pause", timeout: 2.0) {
            let timerTypeAfterForeground = String(describing: lblTimerType.value!)
            XCTAssertTrue(timerTypeAfterForeground == "Focus" || timerTypeAfterForeground == "Short Break")
            XCTAssertTrue(
                waitForValue(lblCounter, notEquals: counterBeforeBackground, timeout: 2.0) ||
                timerTypeAfterForeground == "Short Break"
            )
        } else {
            XCTAssertEqual(playButton.label, "Play")
            // The focus timer elapsed in the background; wait for the UI transition
            // to Short Break to render before asserting — on slow CI this can lag.
            XCTAssertTrue(
                waitForValue(lblTimerType, equals: "Short Break", timeout: 3.0),
                "Timer type should show Short Break after focus session completes in background"
            )
            XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)
        }
    }

    func test_TestAutoStart() {
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        let autoStartToggle = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertTrue(waitForExistence(autoStartToggle, timeout: 5.0), "Auto start toggle should be accessible")
        guard let autoStartValue = autoStartToggle.value as? String else {
            XCTFail("Auto start toggle value should be a String.")
            return
        }
        XCTAssertEqual(autoStartValue, "0")
        tapToggle(autoStartToggle)
        guard let updatedAutoStartValue = autoStartToggle.value as? String else {
            XCTFail("Auto start toggle value should be a String.")
            return
        }
        XCTAssertEqual(updatedAutoStartValue, "1")

        let dismissSettingsButton = application.tabBars.firstMatch.buttons["Timer"]
        dismissSettingsButton.tap()

        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")

        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")

        let lblCounter = application.staticTexts[Accessibility.Identifiers.lblCounter]
        XCTAssertEqual(String(describing: lblCounter.value!), initialCounterLabel)

        playButton.tap()
        XCTAssertTrue(waitForValue(lblTimerType, equals: "Short Break", timeout: 8.0))
        XCTAssertTrue(waitForLabel(playButton, notEquals: "Play", timeout: 5.0))

        // Auto start should run short break automatically, then return to focus.
        XCTAssertTrue(waitForValue(lblTimerType, equals: "Focus", timeout: 10.0))

        XCTAssertTrue(waitForLabel(playButton, notEquals: "Play", timeout: 5.0))
        XCTAssertTrue(waitForValue(lblCounter, notEquals: initialCounterLabel, timeout: 5.0))
    }
}

// MARK: - Long Break Flow

/// Uses 2 Pomodoro cycles so the long break phase is reachable in a short test duration.
/// BaseFeature.setUp() is intentionally not called to avoid launching the app twice with
/// conflicting cycle counts.
final class TimerLongBreakUITests: BaseFeature, @unchecked Sendable {

    override func setUp() {
        MainActor.assumeIsolated {
            application.launchArguments += ["UI-Testing"]
            application.launchEnvironment["UI_TEST_FOCUSED_SECONDS"] = "5"
            application.launchEnvironment["UI_TEST_SHORT_BREAK_SECONDS"] = "5"
            application.launchEnvironment["UI_TEST_LONG_BREAK_SECONDS"] = "5"
            application.launchEnvironment["UI_TEST_NUMBER_OF_CYCLES"] = "2"
            application.launch()
        }
    }

    func test_LongBreakDisplayedAfterAllCycles() {
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        let lblCycleCounter = application.staticTexts[Accessibility.Identifiers.lblCycleCounter]

        XCTAssertEqual(String(describing: lblTimerType.value!), "Focus")
        XCTAssertEqual(String(describing: lblCycleCounter.value!), "0 of 2")

        // 1st focused session → short break (cycle not yet complete)
        playButton.tap()
        XCTAssertTrue(waitForValue(lblTimerType, equals: "Short Break", timeout: 12.0))
        XCTAssertEqual(String(describing: lblCycleCounter.value!), "0 of 2")

        // Short break → 2nd focused session
        XCTAssertTrue(waitForLabel(playButton, equals: "Play", timeout: 3.0))
        playButton.tap()
        XCTAssertTrue(waitForValue(lblTimerType, equals: "Focus", timeout: 12.0))

        // 2nd focused session → long break (all cycles complete)
        XCTAssertTrue(waitForLabel(playButton, equals: "Play", timeout: 3.0))
        playButton.tap()
        XCTAssertTrue(waitForValue(lblTimerType, equals: "Long Break", timeout: 12.0))
        XCTAssertEqual(String(describing: lblCycleCounter.value!), "2 of 2")
    }
}
