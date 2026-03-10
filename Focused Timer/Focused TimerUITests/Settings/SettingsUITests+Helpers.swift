//
//  SettingsUITests+Helpers.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 19/02/26.
//

import XCTest

extension SettingsUITests {

    var showSettingsButton: XCUIElement {
        application.tabBars.firstMatch.buttons["Settings"]
    }

    var dismissSettingsButton: XCUIElement {
        application.tabBars.firstMatch.buttons["Timer"]
    }

    var keepScreenOnToggleAccessibilityLabel: String {
        NSLocalizedString("accLabelSettingsKeepScreenOnToggle", comment: "")
    }

    func assertDefaultSettingsValues() {
        let focusDurationLabel = application.staticTexts[Accessibility.Identifiers.lblFocusDuration]
        XCTAssertTrue(focusDurationLabel.isHittable)

        let shortBreakDurationLabel = application.staticTexts[Accessibility.Identifiers.lblShortBreakDuration]
        XCTAssertTrue(shortBreakDurationLabel.isHittable)

        let longBreakDurationLabel = application.staticTexts[Accessibility.Identifiers.lblLongBreakDuration]
        XCTAssertTrue(longBreakDurationLabel.isHittable)

        let numberOfCyclesLabel = application.staticTexts[Accessibility.Identifiers.lblNumberOfCycles]
        XCTAssertTrue(numberOfCyclesLabel.isHittable)

        let durationTextField = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextField.value!), "1")

        let shortBreakTextField = application.textFields[Accessibility.Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextField.value!), "1")

        let longBreakTextField = application.textFields[Accessibility.Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextField.value!), "1")

        let numberOfCyclesTextField = application.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextField.value!), "4")

        let autoStartToggle = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertEqual(
            stringValue(for: autoStartToggle, message: "Auto start toggle value should be a String."),
            "0"
        )

        scrollToPlaySoundsToggleIfNeeded()
        let playSoundsToggle = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertEqual(
            stringValue(for: playSoundsToggle, message: "Play sounds toggle value should be a String."),
            "0"
        )

        let keepScreenOnToggle = resolvedKeepScreenOnToggle()
        XCTAssertEqual(
            stringValue(for: keepScreenOnToggle, message: "Keep screen on toggle value should be a String."),
            "0"
        )
    }

    func updateSettingsValues() {
        scrollToSettingsTopIfNeeded()

        let durationTextField = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        durationTextField.doubleTap()
        durationTextField.typeText("12345")

        let shortBreakTextField = application.textFields[Accessibility.Identifiers.txtShortBreakTime]
        shortBreakTextField.doubleTap()
        shortBreakTextField.typeText("1234")

        let longBreakTextField = application.textFields[Accessibility.Identifiers.txtLongBreakTime]
        longBreakTextField.doubleTap()
        longBreakTextField.typeText("123")

        let numberOfCyclesTextField = application.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        numberOfCyclesTextField.doubleTap()
        numberOfCyclesTextField.typeText("99")

        application.tap()

        let autoStartToggle = application.switches[Accessibility.Identifiers.tgAutoStart]
        tapToggle(autoStartToggle)

        scrollToPlaySoundsToggleIfNeeded()
        let playSoundsToggle = application.switches[Accessibility.Identifiers.tgPlaySounds]
        tapToggle(playSoundsToggle)

        let keepScreenOnToggle = resolvedKeepScreenOnToggle()
        tapToggle(keepScreenOnToggle)

        let keepScreenOnAlert = application.alerts.firstMatch
        XCTAssertTrue(waitForExistence(keepScreenOnAlert, timeout: 2.0))
        keepScreenOnAlert.buttons["OK"].tap()
    }

    func assertUpdatedSettingsValues() {
        scrollToSettingsTopIfNeeded()
        let durationTextFieldUpdated = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextFieldUpdated.value!), "123")

        let shortBreakTextFieldUpdated = application.textFields[Accessibility.Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextFieldUpdated.value!), "123")

        let longBreakTextFieldUpdated = application.textFields[Accessibility.Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextFieldUpdated.value!), "123")

        let numberOfCyclesTextFieldUpdated = application.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextFieldUpdated.value!), "99")

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

    func resetSettingsToDefaults() {
        application.swipeUp()
        application.buttons[Accessibility.Identifiers.btnResetSettingsDefault].tap()

        XCTAssertTrue(waitForExistence(application.alerts.firstMatch, timeout: 2.0))
        application.alerts.firstMatch.buttons["OK"].tap()

        XCTAssertTrue(waitForExistence(application.alerts.firstMatch, timeout: 2.0))
        application.alerts.firstMatch.buttons["OK"].tap()

        application.swipeDown()
    }

    func assertFinalDefaultSettingsValues() {
        scrollToSettingsTopIfNeeded()
        let durationTextFieldFinal = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        XCTAssertEqual(String(describing: durationTextFieldFinal.value!), "25")

        let shortBreakTextFieldFinal = application.textFields[Accessibility.Identifiers.txtShortBreakTime]
        XCTAssertEqual(String(describing: shortBreakTextFieldFinal.value!), "5")

        let longBreakTextFieldFinal = application.textFields[Accessibility.Identifiers.txtLongBreakTime]
        XCTAssertEqual(String(describing: longBreakTextFieldFinal.value!), "30")

        let numberOfCyclesTextFieldFinal = application.textFields[Accessibility.Identifiers.txtNumberOfCycles]
        XCTAssertEqual(String(describing: numberOfCyclesTextFieldFinal.value!), "4")

        let autoStartToggleFinal = application.switches[Accessibility.Identifiers.tgAutoStart]
        XCTAssertEqual(
            stringValue(for: autoStartToggleFinal, message: "Auto start toggle value should be a String."),
            "0"
        )

        scrollToPlaySoundsToggleIfNeeded()
        let playSoundsToggleFinal = application.switches[Accessibility.Identifiers.tgPlaySounds]
        XCTAssertEqual(
            stringValue(for: playSoundsToggleFinal, message: "Play sounds toggle value should be a String."),
            "0"
        )

        let keepScreenOnToggleFinal = resolvedKeepScreenOnToggle()
        XCTAssertEqual(
            stringValue(for: keepScreenOnToggleFinal, message: "Keep screen on toggle value should be a String."),
            "0"
        )
    }

    func stringValue(
        for element: XCUIElement,
        message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        guard let value = element.value as? String else {
            XCTFail(message, file: file, line: line)
            return ""
        }

        return value
    }

    func tapToggle(_ element: XCUIElement) {
        let nestedSwitch = element.switches.firstMatch
        if nestedSwitch.exists {
            nestedSwitch.tap()
            return
        }

        element.tap()
    }

    func scrollToPlaySoundsToggleIfNeeded(maxSwipes: Int = 3) {
        let toggle = application.switches[Accessibility.Identifiers.tgPlaySounds]
        guard !(toggle.exists && toggle.isHittable) else { return }

        for _ in 0..<maxSwipes {
            application.swipeUp()
            if toggle.exists && toggle.isHittable { return }
        }
    }

    func scrollToKeepScreenOnToggleIfNeeded(maxSwipes: Int = 3) {
        let toggleByIdentifier = application.switches[Accessibility.Identifiers.tgKeepScreenOn]
        let toggleByLabel = application.switches[keepScreenOnToggleAccessibilityLabel]

        if (toggleByIdentifier.exists && toggleByIdentifier.isHittable)
            || (toggleByLabel.exists && toggleByLabel.isHittable) {
            return
        }

        for _ in 0..<maxSwipes {
            application.swipeUp()
            if (toggleByIdentifier.exists && toggleByIdentifier.isHittable)
                || (toggleByLabel.exists && toggleByLabel.isHittable) {
                return
            }
        }
    }

    func scrollToSettingsTopIfNeeded(maxSwipes: Int = 2) {
        let focusTimeTextField = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        if focusTimeTextField.exists && focusTimeTextField.isHittable {
            return
        }

        for _ in 0..<maxSwipes {
            application.swipeDown()
            if focusTimeTextField.exists && focusTimeTextField.isHittable {
                return
            }
        }
    }

    /// Waits for the settings tab to be fully loaded and scrolls to the top of the form.
    /// Tab navigation preserves scroll position, so an explicit scroll-to-top is needed
    /// before asserting top-of-form elements after a tab switch.
    @discardableResult
    func waitForSettingsModalToOpen(timeout: TimeInterval = 5.0) -> Bool {
        scrollToSettingsTopIfNeeded()
        let anchor = application.textFields[Accessibility.Identifiers.txtFocusedTime]
        return waitForExistence(anchor, timeout: timeout)
    }

    func scrollToNotificationsToggleIfNeeded(maxSwipes: Int = 3) {
        let toggle = application.switches[Accessibility.Identifiers.tgEnableNotifications]
        guard !(toggle.exists && toggle.isHittable) else { return }

        for _ in 0..<maxSwipes {
            application.swipeUp()
            if toggle.exists && toggle.isHittable { return }
        }
    }

    func scrollToStartingTimerPickerIfNeeded(maxSwipes: Int = 3) {
        let picker = startingTimerPickerElement()
        guard !(picker.exists && picker.isHittable) else { return }

        for _ in 0..<maxSwipes {
            application.swipeUp()
            if picker.exists && picker.isHittable { return }
        }
    }

    /// Locates the starting timer picker cell regardless of how SwiftUI renders it.
    func startingTimerPickerElement() -> XCUIElement {
        let predicate = NSPredicate(
            format: "identifier == %@",
            Accessibility.Identifiers.pkStartingTimerType
        )
        return application.descendants(matching: .any).matching(predicate).firstMatch
    }

    /// Returns the segment button for a given timer type label within the segmented picker.
    ///
    /// The picker uses `.pickerStyle(.segmented)`, so each option is always visible as a
    /// child button of the picker element — no menu interaction needed.
    func pickerSegment(labeled label: String) -> XCUIElement {
        startingTimerPickerElement().buttons[label]
    }

    /// Resets settings to defaults, dismissing only the alerts that appear (keepScreenOn alert is optional).
    func resetSettingsToDefaultsGracefully() {
        application.swipeUp()
        application.buttons[Accessibility.Identifiers.btnResetSettingsDefault].tap()

        XCTAssertTrue(waitForExistence(application.alerts.firstMatch, timeout: 5.0))
        application.alerts.firstMatch.buttons["OK"].tap()

        if waitForExistence(application.alerts.firstMatch, timeout: 1.5) {
            application.alerts.firstMatch.buttons["OK"].tap()
        }

        application.swipeDown()
    }

    func resolvedKeepScreenOnToggle(file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        scrollToKeepScreenOnToggleIfNeeded()

        let toggleByIdentifier = application.switches[Accessibility.Identifiers.tgKeepScreenOn]
        if toggleByIdentifier.exists {
            return toggleByIdentifier
        }

        let toggleByLabel = application.switches[keepScreenOnToggleAccessibilityLabel]
        if toggleByLabel.exists {
            return toggleByLabel
        }

        // Last fallback: on some layouts this switch can lose both identifier and label.
        let unnamedSwitches = application.switches
            .matching(NSPredicate(format: "identifier == ''"))
            .allElementsBoundByIndex
        let hittableUnnamedSwitches = unnamedSwitches.filter { $0.isHittable }
        let bottomMostUnnamedSwitch = hittableUnnamedSwitches.max(by: { $0.frame.minY < $1.frame.minY })
            ?? unnamedSwitches.max(by: { $0.frame.minY < $1.frame.minY })

        if let unnamedSwitch = bottomMostUnnamedSwitch {
            return unnamedSwitch
        }

        XCTFail("Keep screen on toggle could not be located.", file: file, line: line)
        return toggleByIdentifier
    }
}
