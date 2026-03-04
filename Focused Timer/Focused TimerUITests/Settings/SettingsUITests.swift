//
//  SettingsUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest

final class SettingsUITests: BaseFeature, @unchecked Sendable {

    func test_OpenModalNoChanges() throws {
        // GIVEN I open the modal
        let showSettingsButton = application.buttons[Accessibility.Identifiers.btnShowSettings]
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

        let playSoundsToggle = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggle.isSelected)

        let keepScreenOnToggle = resolvedKeepScreenOnToggle()
        XCTAssertFalse(keepScreenOnToggle.isSelected)

        // WHEN I close the modal
        let dismissSettingsButton = application.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND open it again
        showSettingsButton.tap()

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

        let playSoundsToggleUpdated = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggleUpdated.isSelected)

        let keepScreenOnToggleUpdated = resolvedKeepScreenOnToggle()
        XCTAssertFalse(keepScreenOnToggleUpdated.isSelected)
    }

    func test_UpdateFocusedTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = application.buttons[Accessibility.Identifiers.btnShowSettings]
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
        let dismissSettingsButton = application.buttons[Accessibility.Identifiers.btnCloseModal]
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
        let showSettingsButton = application.buttons[Accessibility.Identifiers.btnShowSettings]
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

        // WHEN I tap to edit the field again
        shortBreakTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        shortBreakTextField.typeText("50")

        let dismissSettingsButton = application.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let shortBreakTextFieldUpdated = String(
            describing: application.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldUpdated, "50")
    }

    func test_UpdateNumberOfCyclesValues() {
        // GIVEN I open the modal
        let showSettingsButton = application.buttons[Accessibility.Identifiers.btnShowSettings]
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

        let dismissSettingsButton = application.buttons[Accessibility.Identifiers.btnCloseModal]
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
        let showSettingsButton = application.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // AND the toggles are in their default values
        let autoStartToggle = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggle.isSelected)

        let playSoundsToggle = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggle.isSelected)

        // WHEN I update the toggles
        tapToggle(autoStartToggle)
        tapToggle(playSoundsToggle)

        let keepScreenOnToggle = resolvedKeepScreenOnToggle()
        tapToggle(keepScreenOnToggle)
        if waitForExistence(application.alerts.firstMatch, timeout: 1.0) {
            application.alerts.firstMatch.buttons["OK"].tap()
        }

        let dismissSettingsButton = application.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        let autoStartToggleUpdated = application.switches[Accessibility.Identifiers.tgAutoStart]
        let playSoundsToggleUpdated = application.switches[Accessibility.Identifiers.tgPlaySounds]

        XCTAssertEqual(
            stringValue(for: autoStartToggleUpdated, message: "Auto start toggle value should be a String."),
            "1"
        )
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
        let showSettingsButton = application.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // THEN the warn should not be displayed
        let lblWarnMessageVisible = application.staticTexts[Accessibility.Identifiers.lblWarnReloadMessage].exists
        XCTAssertFalse(lblWarnMessageVisible, "The warn reload message shouldn't be displayed")

        // WHEN I dismiss the modal
        let dismissSettingsButton = application.buttons[Accessibility.Identifiers.btnCloseModal]
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
        let showSettingsButton = application.buttons[Accessibility.Identifiers.btnShowSettings]
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

    func test_EnableNotificationsToggle_IsOnByDefault() {
        // GIVEN I open the settings modal
        showSettingsButton.tap()

        // WHEN the toggle is loaded
        let notificationsToggle = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(
            waitForExistence(notificationsToggle, timeout: 2.0),
            "The enable notifications toggle should be visible"
        )

        // THEN it should be on by default
        XCTAssertEqual(
            stringValue(for: notificationsToggle, message: "Enable notifications toggle value should be a String."),
            "1",
            "Enable notifications toggle should be on by default"
        )
    }

    func test_EnableNotificationsToggle_PersistsAfterReopeningSettings() {
        // GIVEN I open the settings modal
        showSettingsButton.tap()

        let notificationsToggle = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggle, timeout: 2.0))

        // WHEN I turn off the notifications toggle
        tapToggle(notificationsToggle)

        // AND I dismiss and reopen settings
        dismissSettingsButton.tap()
        showSettingsButton.tap()

        // THEN the toggle should persist as off
        let notificationsToggleUpdated = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggleUpdated, timeout: 2.0))
        XCTAssertEqual(
            stringValue(
                for: notificationsToggleUpdated,
                message: "Enable notifications toggle value should be a String."
            ),
            "0",
            "Enable notifications toggle should be off after being turned off"
        )
    }

    func test_EnableNotificationsToggle_ResetToDefault() {
        // GIVEN I open the settings modal
        showSettingsButton.tap()

        let notificationsToggle = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggle, timeout: 2.0))

        // WHEN I turn off the notifications toggle
        tapToggle(notificationsToggle)

        // AND I reset to defaults (only the reset confirmation alert appears since keepScreenOn was not changed)
        application.swipeUp()
        application.buttons[Accessibility.Identifiers.btnResetSettingsDefault].tap()

        XCTAssertTrue(waitForExistence(application.alerts.firstMatch, timeout: 2.0))
        application.alerts.firstMatch.buttons["OK"].tap()

        // Dismiss any follow-up alert (e.g. keepScreenOn disclaimer) if present
        if waitForExistence(application.alerts.firstMatch, timeout: 1.5) {
            application.alerts.firstMatch.buttons["OK"].tap()
        }

        application.swipeDown()

        // THEN the toggle should be restored to on
        let notificationsToggleReset = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        XCTAssertTrue(waitForExistence(notificationsToggleReset, timeout: 2.0))
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
