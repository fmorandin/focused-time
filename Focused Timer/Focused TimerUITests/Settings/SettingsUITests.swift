//
//  SettingsUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest

// swiftlint:disable type_body_length file_length
final class SettingsUITests: BaseFeature {

    // swiftlint:disable function_body_length
    func test_OpenModalNoChanges() throws {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = app.staticTexts[Accessibility.Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        let shortBreakDurationLabel = app.staticTexts[Accessibility.Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        let longBreakDurationLabel = app.staticTexts[Accessibility.Identifiers.lblLongBreakDuration]
        XCTAssertTrue(longBreakDurationLabel.isHittable)

        let numberOfCyclesLabel = app.staticTexts[Accessibility.Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextField = String(describing: app.textFields[Accessibility.Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextField, "1")

        let shortBreakTextField = String(describing: app.textFields[Accessibility.Identifiers.txtShortBreakTime].value!)
        XCTAssertEqual(shortBreakTextField, "1")

        let numberOfCyclesTextField = String(
            describing: app.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextField, "4")

        let autoStartToggle = app.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggle.isSelected)

        let playSoundsToggle = app.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggle.isSelected)

        let keepScreenOnToggle = app.switches[Accessibility.Identifiers.tgKeepScreenOn]
        XCTAssertFalse(keepScreenOnToggle.isSelected)

        // WHEN I close the modal
        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND open it again
        showSettingsButton.tap()

        // THE duration value should keep the same
        let durationTextFieldUpdated = String(
            describing: app.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextFieldUpdated, "1")

        let shortBreakTextFieldUpdated = String(
            describing: app.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldUpdated, "1")

        let numberOfCyclesTextFieldUpdated = String(
            describing: app.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldUpdated, "4")

        let autoStartToggleUpdated = app.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggleUpdated.isSelected)

        let playSoundsToggleUpdated = app.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggleUpdated.isSelected)

        let keepScreenOnToggleUpdated = app.switches[Accessibility.Identifiers.tgKeepScreenOn]
        XCTAssertFalse(keepScreenOnToggleUpdated.isSelected)
    }

    func test_UpdateFocusedTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = app.staticTexts[Accessibility.Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextFieldValue = String(describing: app.textFields[Accessibility.Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextFieldValue, "1")

        // WHEN I delete the default value
        let durationTextField = app.textFields[Accessibility.Identifiers.txtFocusedTime]
        durationTextField.doubleTap()

        // AND I type an invalid value

        // I was using typeText but it was typing in to fast and, because of that, the char limitation was not working
        // However, if the typing speed is a little more slow (more closer to the velocity of a person taping the screen
        // everything works fine. That was the reason to do the test like this
        app.keys["1"].tap()
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["4"].tap()
        app.keys["5"].tap()
        app.keys["6"].tap()
        app.keys["7"].tap()
        app.keys["8"].tap()

        // THEN the input should only accept 5 digits
        let durationTextFieldInvalidValue = String(
            describing: app.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextFieldInvalidValue.count, 5)
        XCTAssertEqual(durationTextFieldInvalidValue, "12345")

        // WHEN I tap to edit the field again
        durationTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        durationTextField.typeText("100")

        // AND I exit the modal
        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let durationTextFieldUpdated = String(
            describing: app.textFields[Accessibility.Identifiers.txtFocusedTime].value!
        )
        XCTAssertEqual(durationTextFieldUpdated, "100")
    }

    func test_UpdateShortBreakTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let shortBreakDurationLabel = app.staticTexts[Accessibility.Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        // THEN the duration should have the default value
        let shortBreakTextFieldValue = String(
            describing: app.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldValue, "1")

        // WHEN I delete the default value
        let shortBreakTextField = app.textFields[Accessibility.Identifiers.txtShortBreakTime]
        shortBreakTextField.doubleTap()

        // AND I type an invalid value

        // I was using typeText but it was typing in to fast and, because of that, the char limitation was not working
        // However, if the typing speed is a little more slow (more closer to the velocity of a person taping the screen
        // everything works fine. That was the reason to do the test like this
        app.keys["1"].tap()
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["4"].tap()
        app.keys["5"].tap()
        app.keys["6"].tap()
        app.keys["7"].tap()
        app.keys["8"].tap()

        // THEN the input should only accept 5 digits
        let shortBreakTextFieldInvalidValue = String(
            describing: app.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldInvalidValue.count, 5)
        XCTAssertEqual(shortBreakTextFieldInvalidValue, "12345")

        // WHEN I tap to edit the field again
        shortBreakTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        shortBreakTextField.typeText("50")

        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let shortBreakTextFieldUpdated = String(
            describing: app.textFields[Accessibility.Identifiers.txtShortBreakTime].value!
        )
        XCTAssertEqual(shortBreakTextFieldUpdated, "50")
    }

    func test_UpdateNumberOfCyclesValues() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let numberOfCyclesLabel = app.staticTexts[Accessibility.Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the number of cycles should have the default value
        let numberOfCyclesTextFieldValue = String(
            describing: app.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldValue, "4")

        // WHEN I delete the default value
        let numberOfCyclesTextField = app.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        numberOfCyclesTextField.doubleTap()

        // AND I type an invalid value
        numberOfCyclesTextField.typeText("12345678")

        // THEN the input should only accept 2 digits
        let numberOfCyclesTextFieldInvalidValue = String(
            describing: app.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldInvalidValue.count, 2)
        XCTAssertEqual(numberOfCyclesTextFieldInvalidValue, "12")

        // WHEN I tap to edit the field again
        numberOfCyclesTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        numberOfCyclesTextField.typeText("20")

        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let numberOfCyclesTextFieldUpdated = String(
            describing: app.textFields[Accessibility.Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldUpdated, "20")
    }

    // swiftlint:disable force_cast
    func test_UpdateToggles() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // AND the toggles are in their default values
        let autoStartToggle = app.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggle.isSelected)

        let playSoundsToggle = app.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertFalse(playSoundsToggle.isSelected)

        let keepScreenOnToggle = app.switches[Accessibility.Identifiers.tgKeepScreenOn]
        XCTAssertFalse(keepScreenOnToggle.isSelected)

        // WHEN I update the toggles
        autoStartToggle.tap()
        playSoundsToggle.tap()
        keepScreenOnToggle.tap()

        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        XCTAssertEqual(autoStartToggle.value as! String, "1")
        XCTAssertEqual(playSoundsToggle.value as! String, "1")
        XCTAssertEqual(keepScreenOnToggle.value as! String, "1")
    }

    func test_WarnMessageWhenTimerIsRunning() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // THEN the warn should not be displayed
        let lblWarnMessageVisible = app.staticTexts[Accessibility.Identifiers.lblWarnReloadMessage].exists
        XCTAssertFalse(lblWarnMessageVisible, "The warn reload message shouldn't be displayed")

        // WHEN I dismiss the modal
        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I start the timer
        let playButton = app.buttons[Accessibility.Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")
        playButton.tap()

        sleep(2) // This was used to let the timer run a little before procceed

        // AND open it again
        showSettingsButton.tap()

        // THEN the warning should be displayed
        let lblWarnMessageVisibleUpdated = app.staticTexts[Accessibility.Identifiers.lblWarnReloadMessage].exists
        XCTAssert(lblWarnMessageVisibleUpdated, "The warn reload message should be displayed")
    }

    // swiftlint:disable function_body_length
    func test_ResetToDefault() {

        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = app.staticTexts[Accessibility.Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        let shortBreakDurationLabel = app.staticTexts[Accessibility.Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        let longBreakDurationLabel = app.staticTexts[Accessibility.Identifiers.lblLongBreakDuration]
        XCTAssertTrue(longBreakDurationLabel.isHittable)

        let numberOfCyclesLabel = app.staticTexts[Accessibility.Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextField = app.textFields[Accessibility.Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextField.value!), "1")

        let shortBreakTextField = app.textFields[Accessibility.Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextField.value!), "1")

        let longBreakTextField = app.textFields[Accessibility.Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextField.value!), "1")

        let numberOfCyclesTextField = app.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextField.value!), "4")

        let autoStartToggle = app.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertEqual(autoStartToggle.value as! String, "0")

        let playSoundsToggle = app.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertEqual(playSoundsToggle.value as! String, "0")

        let keepScreenOnToggle = app.switches[Accessibility.Identifiers.tgKeepScreenOn]
        XCTAssertEqual(keepScreenOnToggle.value as! String, "0")

        // WHEN I update the fields
        durationTextField.doubleTap()
        durationTextField.typeText("12345")

        shortBreakTextField.doubleTap()
        shortBreakTextField.typeText("1234")

        longBreakTextField.doubleTap()
        longBreakTextField.typeText("123")

        numberOfCyclesTextField.doubleTap()
        numberOfCyclesTextField.typeText("99")

        autoStartToggle.tap()
        playSoundsToggle.tap()
        keepScreenOnToggle.tap()

        // AND I dismiss the modal
        let dismissSettingsButton = app.buttons[Accessibility.Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open it again
        showSettingsButton.tap()

        // THEN all the values that were updated should be correct
        let durationTextFieldUpdated = app.textFields[Accessibility.Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextFieldUpdated.value!), "12345")

        let shortBreakTextFieldUpdated = app.textFields[Accessibility.Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextFieldUpdated.value!), "1234")

        let longBreakTextFieldUpdated = app.textFields[Accessibility.Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextFieldUpdated.value!), "123")

        let numberOfCyclesTextFieldUpdated = app.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextFieldUpdated.value!), "99")

        let autoStartToggleUpdated = app.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertEqual(autoStartToggleUpdated.value as! String, "1")

        let playSoundsToggleUpdated = app.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertEqual(playSoundsToggleUpdated.value as! String, "1")

        let keepScreenOnToggleUpdated = app.switches[Accessibility.Identifiers.tgKeepScreenOn]
        XCTAssertEqual(keepScreenOnToggleUpdated.value as! String, "1")

        // WHEN I click to reset to the defaults
        app.buttons[Accessibility.Identifiers.btnResetSettingsDefault].tap()

        // AND I confirm in the modal
        app.alerts.firstMatch.buttons["OK"].tap()

        sleep(1)

        // THEN all the values should be back to the default
        let durationTextFieldFinal = app.textFields[Accessibility.Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextFieldFinal.value!), "25")

        let shortBreakTextFieldFinal = app.textFields[Accessibility.Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextFieldFinal.value!), "5")

        let longBreakTextFieldFinal = app.textFields[Accessibility.Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextFieldFinal.value!), "30")

        let numberOfCyclesTextFieldFinal = app.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextFieldFinal.value!), "4")

        let autoStartToggleFinal = app.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertEqual(autoStartToggleFinal.value as! String, "0")

        let playSoundsToggleFinal = app.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertEqual(playSoundsToggleFinal.value as! String, "0")

        let keepScreenOnToggleFinal = app.switches[Accessibility.Identifiers.tgKeepScreenOn]
        XCTAssertEqual(keepScreenOnToggleFinal.value as! String, "0")
    }

    func test_AppVersionAndShare() {

        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Accessibility.Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // THEN the about information should be visible
        let appVersionText = app.staticTexts[Accessibility.Identifiers.lblAppVersion]
        XCTAssertEqual(appVersionText.label, "App Version: 1.3.0")

        // AND the share option should be visible
        let btnShareApp = app.buttons[Accessibility.Identifiers.btnShareApp]
        XCTAssertEqual(btnShareApp.label, "Share it")

        // WHEN I tap on the share
        btnShareApp.tap()

        // THEN the share sheet should be displayed
        let shareSheet = app.navigationBars.firstMatch
        XCTAssertTrue(shareSheet.isHittable, "The share sheet should be displayed")
    }
}
