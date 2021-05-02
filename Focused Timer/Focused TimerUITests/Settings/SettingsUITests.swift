//
//  SettingsUITests.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest

class SettingsUITests: BaseFeature {

    func test_OpenModalNoChanges() throws {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = app.staticTexts[Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        let shortBreakDurationLabel = app.staticTexts[Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        let longBreakDurationLabel = app.staticTexts[Identifiers.lblLongBreakDuration]
        XCTAssertTrue(longBreakDurationLabel.isHittable)

        let numberOfCyclesLabel = app.staticTexts[Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextField = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextField, "1")

        let shortBreakTextField = String(describing: app.textFields[Identifiers.txtShortBreakTime].value!)
        XCTAssertEqual(shortBreakTextField, "1")

        let numberOfCyclesTextField = String(describing: app.textFields[Identifiers.txtNumberOfCycles].value!)
        XCTAssertEqual(numberOfCyclesTextField, "4")

        let autoStartToggle = app.switches[Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggle.isSelected)

        // WHEN I close the modal
        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND open it again
        showSettingsButton.tap()

        // THE duration value should keep the same
        let durationTextFieldUpdated = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextFieldUpdated, "1")

        let shortBreakTextFieldUpdated = String(describing: app.textFields[Identifiers.txtShortBreakTime].value!)
        XCTAssertEqual(shortBreakTextFieldUpdated, "1")

        let numberOfCyclesTextFieldUpdated = String(describing: app.textFields[Identifiers.txtNumberOfCycles].value!)
        XCTAssertEqual(numberOfCyclesTextFieldUpdated, "4")

        let autoStartToggleUpdated = app.switches[Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggleUpdated.isSelected)
    }

    func test_UpdateFocusedTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = app.staticTexts[Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextFieldValue = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextFieldValue, "1")

        // WHEN I delete the default value
        let durationTextField = app.textFields[Identifiers.txtFocusedTime]
        durationTextField.doubleTap()

        // AND I type an invalid value
        durationTextField.typeText("12345678")

        // THEN the input should only accept 5 digits
        let durationTextFieldInvalidValue = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextFieldInvalidValue.count, 5)
        XCTAssertEqual(durationTextFieldInvalidValue, "12345")

        // WHEN I tap to edit the field again
        durationTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        durationTextField.typeText("100")

        // AND I exit the modal
        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let durationTextFieldUpdated = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextFieldUpdated, "100")
    }

    func test_UpdateShortBreakTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let shortBreakDurationLabel = app.staticTexts[Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        // THEN the duration should have the default value
        let shortBreakTextFieldValue = String(describing: app.textFields[Identifiers.txtShortBreakTime].value!)
        XCTAssertEqual(shortBreakTextFieldValue, "1")

        // WHEN I delete the default value
        let shortBreakTextField = app.textFields[Identifiers.txtShortBreakTime]
        shortBreakTextField.doubleTap()

        // AND I type an invalid value
        shortBreakTextField.typeText("12345678")

        // THEN the input should only accept 5 digits
        let shortBreakTextFieldInvalidValue = String(describing: app.textFields[Identifiers.txtShortBreakTime].value!)
        XCTAssertEqual(shortBreakTextFieldInvalidValue.count, 5)
        XCTAssertEqual(shortBreakTextFieldInvalidValue, "12345")

        // WHEN I tap to edit the field again
        shortBreakTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        shortBreakTextField.typeText("50")

        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let shortBreakTextFieldUpdated = String(describing: app.textFields[Identifiers.txtShortBreakTime].value!)
        XCTAssertEqual(shortBreakTextFieldUpdated, "50")
    }

    func test_UpdateNumberOfCyclesValues() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let numberOfCyclesLabel = app.staticTexts[Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the number of cycles should have the default value
        let numberOfCyclesTextFieldValue = String(describing: app.textFields[Identifiers.txtNumberOfCycles].value!)
        XCTAssertEqual(numberOfCyclesTextFieldValue, "4")

        // WHEN I delete the default value
        let numberOfCyclesTextField = app.textFields[Identifiers.txtNumberOfCycles]
        numberOfCyclesTextField.doubleTap()

        // AND I type an invalid value
        numberOfCyclesTextField.typeText("12345678")

        // THEN the input should only accept 2 digits
        let numberOfCyclesTextFieldInvalidValue = String(
            describing: app.textFields[Identifiers.txtNumberOfCycles].value!
        )
        XCTAssertEqual(numberOfCyclesTextFieldInvalidValue.count, 2)
        XCTAssertEqual(numberOfCyclesTextFieldInvalidValue, "12")

        // WHEN I tap to edit the field again
        numberOfCyclesTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5))

        // AND I add the new value
        numberOfCyclesTextField.typeText("20")

        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let numberOfCyclesTextFieldUpdated = String(describing: app.textFields[Identifiers.txtNumberOfCycles].value!)
        XCTAssertEqual(numberOfCyclesTextFieldUpdated, "20")
    }

    // swiftlint:disable force_cast
    func test_UpdateToggles() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN I update the toggles
        let autoStartToggle = app.switches[Identifiers.tgAutoStart]
        XCTAssertFalse(autoStartToggle.isSelected)
        autoStartToggle.tap()

        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        XCTAssertEqual(autoStartToggle.value as! String, "1")
    }

    func test_WarnMessageWhenTimerIsRunning() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // THEN the warn should not be displayed
        let lblWarnMessageVisible = app.staticTexts[Identifiers.lblWarnReloadMessage].exists
        XCTAssertFalse(lblWarnMessageVisible, "The warn reload message shouldn't be displayed")

        // WHEN I dismiss the modal
        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I start the timer
        let playButton = app.buttons[Identifiers.btnStartPauseIdentifier]
        XCTAssertEqual(playButton.label, "Play")
        playButton.tap()

        sleep(2) // This was used to let the timer run a little before procceed

        // AND open it again
        showSettingsButton.tap()

        // THEN the warning should be displayed
        let lblWarnMessageVisibleUpdated = app.staticTexts[Identifiers.lblWarnReloadMessage].exists
        XCTAssert(lblWarnMessageVisibleUpdated, "The warn reload message should be displayed")
    }

    // swiftlint:disable function_body_length
    func test_ResetToDefault() {

        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let focusDurationLabel = app.staticTexts[Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        let shortBreakDurationLabel = app.staticTexts[Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        let longBreakDurationLabel = app.staticTexts[Identifiers.lblLongBreakDuration]
        XCTAssertTrue(longBreakDurationLabel.isHittable)

        let numberOfCyclesLabel = app.staticTexts[Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextField = app.textFields[Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextField.value!), "1")

        let shortBreakTextField = app.textFields[Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextField.value!), "1")

        let longBreakTextField = app.textFields[Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextField.value!), "1")

        let numberOfCyclesTextField = app.textFields[Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextField.value!), "4")

        let autoStartToggle = app.switches[Identifiers.tgAutoStart]
        XCTAssertEqual(autoStartToggle.value as! String, "0")

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

        // AND I dismiss the modal
        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open it again
        showSettingsButton.tap()

        // THEN all the values that were updated should be correct
        let durationTextFieldUpdated = app.textFields[Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextFieldUpdated.value!), "12345")

        let shortBreakTextFieldUpdated = app.textFields[Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextFieldUpdated.value!), "1234")

        let longBreakTextFieldUpdated = app.textFields[Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextFieldUpdated.value!), "123")

        let numberOfCyclesTextFieldUpdated = app.textFields[Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextFieldUpdated.value!), "99")

        let autoStartToggleUpdated = app.switches[Identifiers.tgAutoStart]
        XCTAssertEqual(autoStartToggleUpdated.value as! String, "1")

        // WHEN I click to reset to the defaults
        app.buttons[Identifiers.btnResetSettingsDefault].tap()

        // AND I confirm in the modal
        app.alerts.firstMatch.buttons["OK"].tap()

        sleep(1)

        // THEN all the values should be back to the default
        let durationTextFieldFinal = app.textFields[Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextFieldFinal.value!), "25")

        let shortBreakTextFieldFinal = app.textFields[Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextFieldFinal.value!), "5")

        let longBreakTextFieldFinal = app.textFields[Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextFieldFinal.value!), "30")

        let numberOfCyclesTextFieldFinal = app.textFields[Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextFieldFinal.value!), "4")

        let autoStartToggleFinal = app.switches[Identifiers.tgAutoStart]
        XCTAssertEqual(autoStartToggleFinal.value as! String, "0")
    }
}
