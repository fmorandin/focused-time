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

        let restDurationLabel = app.staticTexts[Identifiers.lblRestDuration]
        XCTAssertTrue(restDurationLabel.isHittable)

        // THEN the duration should have the default value
        let durationTextField = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextField, "1")

        let restTextField = String(describing: app.textFields[Identifiers.txtRestTime].value!)
        XCTAssertEqual(restTextField, "1")

        let numberOfCyclesTextField = String(describing: app.textFields[Identifiers.txtCycleTotal].value!)
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

        let restTextFieldUpdated = String(describing: app.textFields[Identifiers.txtRestTime].value!)
        XCTAssertEqual(restTextFieldUpdated, "1")

        let numberOfCyclesTextFieldUpdated = String(describing: app.textFields[Identifiers.txtCycleTotal].value!)
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

    func test_UpdateRestTimerValue() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let restDurationLabel = app.staticTexts[Identifiers.lblRestDuration]
        XCTAssertTrue(restDurationLabel.isHittable)

        // THEN the duration should have the default value
        let restTextFieldValue = String(describing: app.textFields[Identifiers.txtRestTime].value!)
        XCTAssertEqual(restTextFieldValue, "1")

        // WHEN I delete the default value
        let restTextField = app.textFields[Identifiers.txtRestTime]
        restTextField.doubleTap()

        // AND I add the new value
        restTextField.typeText("50")

        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let restTextFieldUpdated = String(describing: app.textFields[Identifiers.txtRestTime].value!)
        XCTAssertEqual(restTextFieldUpdated, "50")
    }

    func test_UpdateNumberOfCyclesValues() {
        // GIVEN I open the modal
        let showSettingsButton = app.buttons[Identifiers.btnShowSettings]
        showSettingsButton.tap()

        // WHEN the fields are loaded
        let restNumberOfCyclesLabel = app.staticTexts[Identifiers.lblCycleTotal]
        XCTAssertTrue(restNumberOfCyclesLabel.isHittable)

        // THEN the number of cycles should have the default value
        let numberOfCyclesTextFieldValue = String(describing: app.textFields[Identifiers.txtCycleTotal].value!)
        XCTAssertEqual(numberOfCyclesTextFieldValue, "4")

        // WHEN I delete the default value
        let numberOfCyclesTextField = app.textFields[Identifiers.txtCycleTotal]
        numberOfCyclesTextField.doubleTap()

        // AND I add the new value
        numberOfCyclesTextField.typeText("20")

        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let numberOfCyclesTextFieldUpdated = String(describing: app.textFields[Identifiers.txtCycleTotal].value!)
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
}
