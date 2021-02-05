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

        // THEN the duration should have the default value
        let durationTextField = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextField, "1")

        // WHEN I close the modal
        let dismissSettingsButton = app.buttons[Identifiers.btnCloseModal]
        dismissSettingsButton.tap()

        // AND open it again
        showSettingsButton.tap()

        // THE duration value should keep the same
        let durationTextFieldUpdated = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextFieldUpdated, "1")
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

        // AND I click to save
        let saveButton = app.buttons[Identifiers.btnSaveSettings]
        saveButton.tap()

        // AND I open the modal again
        showSettingsButton.tap()

        // THEN the value should be the one that was updated
        let durationTextFieldUpdated = String(describing: app.textFields[Identifiers.txtFocusedTime].value!)
        XCTAssertEqual(durationTextFieldUpdated, "100")
    }

}
