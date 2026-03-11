//
//  SettingsUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 31/01/21.
//

// swiftlint:disable file_length
import XCTest

// swiftlint:disable:next type_body_length
final class SettingsUITests: BaseFeature, @unchecked Sendable {

    // swiftlint:disable:next function_body_length
    func test_OpenModalNoChanges() throws {
        // GIVEN I open the modal
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = application.staticTexts[Accessibility.Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        let shortBreakDurationLabel = application.staticTexts[Accessibility.Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        let longBreakDurationLabel = application.staticTexts[Accessibility.Identifiers.lblLongBreakDuration]
        XCTAssertTrue(longBreakDurationLabel.isHittable)

        let numberOfCyclesLabel = application.staticTexts[Accessibility.Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextField = String(
            describing: application.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextField, "1")

        let shortBreakTextField = String(
            describing: application.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextField, "1")

        let numberOfCyclesTextField = String(
            describing: application.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextField, "4")

        let autoStartToggle = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggle.isSelected)

        scrollToPlaySoundsToggleIfNeeded()
        let playSoundsToggle = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggle.isSelected)

        let keepScreenOnToggle = resolvedKeepScreenOnToggle()
        XCTAssertFalse(keepScreenOnToggle.isSelected)

        // WHEN I close the modal
        let dismissSettingsButton = application.tabBars.firstMatch.buttons["Timer"]
        dismissSettingsButton.tap()

        // AND open it again
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings should reopen at the top")

        // THE duration value should keep the same
        let durationTextFieldUpdated = String(
            describing: application.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextFieldUpdated, "1")

        let shortBreakTextFieldUpdated = String(
            describing: application.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldUpdated, "1")

        let numberOfCyclesTextFieldUpdated = String(
            describing: application.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldUpdated, "4")

        let autoStartToggleUpdated = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggleUpdated.isSelected)

        scrollToPlaySoundsToggleIfNeeded()
        let playSoundsToggleUpdated = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggleUpdated.isSelected)

        let keepScreenOnToggleUpdated = resolvedKeepScreenOnToggle()
        XCTAssertFalse(keepScreenOnToggleUpdated.isSelected)
    }

    func test_UpdateFocusedTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = application.staticTexts[Accessibility.Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextFieldValue = String(
            describing: application.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextFieldValue, "1")

        // WHEN I delete the default value
        let durationTextField = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        durationTextField.doubleTap()

        // AND I type an invalid value

        // I was using typeText but it was typing in to fast and, because of that, the char limitation was not working
        // However, if the typing speed is a little more slow (more closer to the velocity of a person taping the screen
        // everything works fine. That was the reason to do the test like this
        slowTypeText("12345678", into: durationTextField)

        // THEN the input should only accept 5 digits
        let durationTextFieldInvalidValue = String(
            describing: application.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextFieldInvalidValue.count, 3)
        XCTAssertEqual(durationTextFieldInvalidValue, "123")

        // WHEN I tap to edit the field again
        durationTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        durationTextField.typeText("100")

        // AND I exit the modal
        let dismissSettingsButton = application.tabBars.firstMatch.buttons["Timer"]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let durationTextFieldUpdated = String(
            describing: application.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextFieldUpdated, "100")
    }

    func test_UpdateShortBreakTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let shortBreakDurationLabel = application.staticTexts[Accessibility.Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        // THEN the duration should have the default value
        let shortBreakTextFieldValue = String(
            describing: application.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldValue, "1")

        // WHEN I delete the default value
        let shortBreakTextField = application.textFields[Accessibility.Identifiers.txtShortBreakTime]
        shortBreakTextField.doubleTap()

        // AND I type an invalid value

        // I was using typeText but it was typing in to fast and, because of that, the char limitation was not working
        // However, if the typing speed is a little more slow (more closer to the velocity of a person taping the screen
        // everything works fine. That was the reason to do the test like this
        slowTypeText("12345678", into: shortBreakTextField)

        // THEN the input should only accept 5 digits
        let shortBreakTextFieldInvalidValue = String(
            describing: application.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldInvalidValue.count, 3)
        XCTAssertEqual(shortBreakTextFieldInvalidValue, "123")

        // WHEN I tap to edit the field again (explicit tap required — typeText does not auto-focus)
        shortBreakTextField.tap()
        shortBreakTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        shortBreakTextField.tap()
        shortBreakTextField.typeText("50")

        let dismissSettingsButton = application.tabBars.firstMatch.buttons["Timer"]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings should reload after reopening")

        // THEN the value should be the one that was updated.
        // Wait for the binding to settle before reading — on slow CI the field can
        // briefly show a stale value right after the tab transition completes.
        let shortBreakTextFieldUpdated = application.textFields[Accessibility.Identifiers.txtShortBreakTime]
        XCTAssertTrue(
            waitForValue(shortBreakTextFieldUpdated, equals: "50", timeout: 5.0),
            "Short break field should display '50' after settings are reopened"
        )
    }

    func test_UpdateNumberOfCyclesValues() {
        // GIVEN I open the modal
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let numberOfCyclesLabel = application.staticTexts[Accessibility.Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the number of cycles should have the default value
        let numberOfCyclesTextFieldValue = String(
            describing: application.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldValue, "4")

        // WHEN I delete the default value
        let numberOfCyclesTextField = application.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        numberOfCyclesTextField.tap()
        numberOfCyclesTextField.typeText(XCUIKeyboardKey.delete.rawValue)

        // AND I type an invalid value
        slowTypeText("12345678", into: numberOfCyclesTextField)

        // THEN the input should only accept 2 digits
        let numberOfCyclesTextFieldInvalidValue = String(
            describing: application.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldInvalidValue.count, 2)
        XCTAssertEqual(numberOfCyclesTextFieldInvalidValue, "12")

        // WHEN I tap to edit the field again
        numberOfCyclesTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 2))

        // AND I add the new value
        numberOfCyclesTextField.typeText("20")

        let dismissSettingsButton = application.tabBars.firstMatch.buttons["Timer"]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let numberOfCyclesTextFieldUpdated = String(
            describing: application.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldUpdated, "20")
    }

    func test_UpdateToggles() {
        // GIVEN I open the modal
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        // AND the toggles are in their default values
        let autoStartToggle = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggle.isSelected)

        scrollToPlaySoundsToggleIfNeeded()
        let playSoundsToggle = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggle.isSelected)

        // WHEN I update the toggles
        tapToggle(autoStartToggle)
        scrollToPlaySoundsToggleIfNeeded()
        tapToggle(playSoundsToggle)

        let keepScreenOnToggle = resolvedKeepScreenOnToggle()
        tapToggle(keepScreenOnToggle)
        if waitForExistence(application.alerts.firstMatch, timeout: 1.0) {
            application.alerts.firstMatch.buttons["OK"].tap()
        }

        let dismissSettingsButton = application.tabBars.firstMatch.buttons["Timer"]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should reopen")

        let autoStartToggleUpdated = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertEqual(
            stringValue(for: autoStartToggleUpdated, message: "Auto start toggle value should be a String."),
            "1"
        )

        scrollToPlaySoundsToggleIfNeeded()
        let playSoundsToggleUpdated = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertEqual(
            stringValue(for: playSoundsToggleUpdated, message: "Play sounds toggle value should be a String."),
            "1"
        )

        let keepScreenOnToggleUpdated = resolvedKeepScreenOnToggle()
        XCTAssertEqual(
            stringValue(for: keepScreenOnToggleUpdated, message: "Keep screen on toggle value should be a String."),
            "1"
        )
    }

    func test_WarnMessageWhenTimerIsRunning() {
        // GIVEN I open the modal
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        // THEN the warn should not be displayed
        let lblWarnMessageVisible = application.staticTexts[Accessibility.Identifiers.lblWarnReloadMessage].exists
        XCTAssertFalse(lblWarnMessageVisible, "The warn reload message shouldn't be displayed")

        // WHEN I dismiss the modal
        let dismissSettingsButton = application.tabBars.firstMatch.buttons["Timer"]
        dismissSettingsButton.tap()

        // AND I start the timer
        let playButton = application.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")
        playButton.tap()

        XCTAssertTrue(waitForLabel(playButton, equals: "Pause", timeout: 2.0))

        // AND open it again
        showSettingsButton.tap()

        // THEN the warning should be displayed
        let lblWarnMessageVisibleUpdated = application.staticTexts[
            Accessibility.Identifiers.lblWarnReloadMessage
        ].exists
        XCTAssert(lblWarnMessageVisibleUpdated, "The warn reload message should be displayed")
    }

    func test_ResetToDefault() {
        showSettingsButton.tap()

        assertDefaultSettingsValues()
        updateSettingsValues()

        dismissSettingsButton.tap()
        showSettingsButton.tap()

        assertUpdatedSettingsValues()
        resetSettingsToDefaults()
        assertFinalDefaultSettingsValues()
    }

    func test_AppVersionAndShare() {

        // GIVEN I open the modal
        let showSettingsButton = application.tabBars.firstMatch.buttons["Settings"]
        showSettingsButton.tap()

        application.swipeUp()

        // THEN the about information should be visible
        let appVersionText = application.staticTexts[Accessibility.Identifiers.lblAppVersion]
        XCTAssertEqual(appVersionText.label, "App Version: 2.0.0")

        // AND the share option should be visible
        let btnShareApp = application.buttons[Accessibility.Identifiers.btnShareApp]
        XCTAssertEqual(btnShareApp.label, "Share it")

        // WHEN I tap on the share
        btnShareApp.tap()

        // THEN the share sheet should be displayed
        let shareSheetAppeared =
            application.otherElements["ActivityListView"].waitForExistence(timeout: 3.0) ||
            application.sheets.firstMatch.waitForExistence(timeout: 3.0) ||
            application.navigationBars.firstMatch.waitForExistence(timeout: 3.0)

        XCTAssertTrue(shareSheetAppeared, "The share sheet should be displayed")
    }

    func test_StartingTimerTypePicker_IsVisibleAndDefaultsToFocus() {
        // GIVEN the timer screen is visible with no custom starting type set
        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertTrue(waitForExistence(lblTimerType, timeout: 5.0), "Timer type label should be visible")

        // THEN the default starting timer type should be Focus
        XCTAssertEqual(lblTimerType.label, "Focus", "Timer should start as Focus by default")

        // WHEN I open settings
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should open")

        // THEN the starting timer picker is visible
        scrollToStartingTimerPickerIfNeeded()
        let picker = startingTimerPickerElement()
        XCTAssertTrue(
            waitForExistence(picker, timeout: 5.0),
            "The starting timer type picker should be visible in settings"
        )
    }

    func test_StartingTimerTypePicker_PersistsThroughTimerReset() {
        // GIVEN I open settings and set Short Break as the starting timer
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should open")

        scrollToStartingTimerPickerIfNeeded()
        XCTAssertTrue(waitForExistence(startingTimerPickerElement(), timeout: 5.0))

        let shortBreakSegment = pickerSegment(labeled: "Short Break")
        XCTAssertTrue(waitForExistence(shortBreakSegment, timeout: 5.0), "Short Break segment should be visible")
        shortBreakSegment.tap()

        // WHEN I close settings (timer resets to the new starting type)
        dismissSettingsButton.tap()

        // THEN the timer shows Short Break (wait for async reset to propagate)
        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertTrue(
            waitForLabel(lblTimerType, equals: "Short Break", timeout: 5.0),
            "Timer should show Short Break after settings update"
        )

        // WHEN I tap the reset button (uses the stored starting type from UserDefaults)
        let resetButton = application.buttons[Accessibility.Identifiers.btnResetIdentifier]
        XCTAssertTrue(waitForExistence(resetButton, timeout: 3.0))
        resetButton.tap()

        // THEN the timer still shows Short Break — proving UserDefaults persistence
        XCTAssertTrue(
            waitForLabel(lblTimerType, equals: "Short Break", timeout: 5.0),
            "Timer should remain Short Break after reset, proving UserDefaults persistence"
        )
    }

    func test_StartingTimerTypePicker_ResetsToFocusOnResetToDefault() {
        // GIVEN I open settings and set Long Break as the starting timer
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should open")

        scrollToStartingTimerPickerIfNeeded()
        XCTAssertTrue(waitForExistence(startingTimerPickerElement(), timeout: 5.0))

        let longBreakSegment = pickerSegment(labeled: "Long Break")
        XCTAssertTrue(waitForExistence(longBreakSegment, timeout: 5.0), "Long Break segment should be visible")
        longBreakSegment.tap()

        // AND close settings (timer resets to Long Break, wait for async propagation)
        dismissSettingsButton.tap()
        let lblTimerType = application.staticTexts[Accessibility.Identifiers.lblTimerType]
        XCTAssertTrue(
            waitForLabel(lblTimerType, equals: "Long Break", timeout: 5.0),
            "Timer should show Long Break after settings update"
        )

        // WHEN I reopen settings and reset to defaults
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should reopen")
        resetSettingsToDefaultsGracefully()

        // THEN the timer shows Focus again after settings are closed (wait for async reset)
        dismissSettingsButton.tap()
        XCTAssertTrue(
            waitForLabel(lblTimerType, equals: "Focus", timeout: 5.0),
            "Timer should show Focus after resetting settings to defaults"
        )
    }

    func test_EnableNotificationsToggle_IsOnByDefault() {
        // GIVEN I open the settings modal
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should open")

        // WHEN I scroll to the notifications toggle
        scrollToNotificationsToggleIfNeeded()
        let notificationsToggle = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(
            waitForExistence(notificationsToggle, timeout: 5.0),
            "The enable notifications toggle should be visible"
        )

        // THEN it should be on by default
        XCTAssertEqual(
            stringValue(for: notificationsToggle, message: "Enable notifications toggle value should be a String."),
            "1",
            "Enable notifications toggle should be on by default"
        )
    }

    func test_EnableNotificationsToggle_PersistsAfterReopeningSettings() throws {
        // GIVEN I open the settings modal
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should open")

        scrollToNotificationsToggleIfNeeded()
        let notificationsToggle = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggle, timeout: 5.0))

        // Skip when the system has denied notifications — the toggle is disabled
        // and cannot be interacted with.
        try XCTSkipUnless(
            notificationsToggle.isEnabled,
            "Notifications denied at system level — toggle is disabled"
        )

        // WHEN I turn off the notifications toggle
        tapToggle(notificationsToggle)

        // AND I dismiss and reopen settings
        dismissSettingsButton.tap()
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should reopen")

        // THEN the toggle should persist as off
        scrollToNotificationsToggleIfNeeded()
        let notificationsToggleUpdated = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggleUpdated, timeout: 5.0))
        XCTAssertEqual(
            stringValue(
                for: notificationsToggleUpdated,
                message: "Enable notifications toggle value should be a String."
            ),
            "0",
            "Enable notifications toggle should be off after being turned off"
        )
    }

    func test_EnableNotificationsToggle_ResetToDefault() throws {
        // GIVEN I open the settings modal
        showSettingsButton.tap()
        XCTAssertTrue(waitForSettingsModalToOpen(), "Settings modal should open")

        scrollToNotificationsToggleIfNeeded()
        let notificationsToggle = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggle, timeout: 5.0))

        // Skip when the system has denied notifications — the toggle is disabled
        // and cannot be interacted with.
        try XCTSkipUnless(
            notificationsToggle.isEnabled,
            "Notifications denied at system level — toggle is disabled"
        )

        // WHEN I turn off the notifications toggle
        tapToggle(notificationsToggle)

        // AND I reset to defaults (only the reset confirmation alert appears since keepScreenOn was not changed)
        application.swipeUp()
        application.buttons[Accessibility.Identifiers.btnResetSettingsDefault].tap()

        XCTAssertTrue(waitForExistence(application.alerts.firstMatch, timeout: 5.0))
        application.alerts.firstMatch.buttons["OK"].tap()

        // Dismiss any follow-up alert (e.g. keepScreenOn disclaimer) if present
        if waitForExistence(application.alerts.firstMatch, timeout: 1.5) {
            application.alerts.firstMatch.buttons["OK"].tap()
        }

        application.swipeDown()

        // THEN the toggle should be restored to on
        scrollToNotificationsToggleIfNeeded()
        let notificationsToggleReset = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggleReset, timeout: 5.0))
        XCTAssertEqual(
            stringValue(
                for: notificationsToggleReset,
                message: "Enable notifications toggle value should be a String."
            ),
            "1",
            "Enable notifications toggle should be on after reset to defaults"
        )
    }

}
