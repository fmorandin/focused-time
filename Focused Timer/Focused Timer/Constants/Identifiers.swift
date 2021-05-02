//
//  Identifiers.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/02/21.
//

import Foundation

enum Identifiers {
    // MARK: - Settings Screen

    // Buttons
    static let btnCloseModal = "btnDismissSettings"
    static let btnResetSettingsDefault = "btnResetSettingsDefault"

    // TextFields
    static let txtFocusedTime = "txtFocusedTime"
    static let txtShortBreakTime = "txtShortBreakTime"
    static let txtNumberOfCycles = "txtNumberOfCycles"
    static let txtLongBreakTime = "txtLongBreakTime"

    // Toggles
    static let tgAutoStart = "tgAutoStart"

    // Labels
    static let lblFocusDuration = "lblFocusDuration"
    static let lblShortBreakDuration = "lblShortBreakDuration"
    static let lblNumberOfCycles = "lblNumberOfCycles"
    static let lblLongBreakDuration = "lblLongBreakDuration"
    static let lblAutoStart = "lblAutoStart"

    static let lblWarnReloadMessage = "lblWarnReloadMessage"

    // MARK: - Timer Screen

    // Buttons
    static let btnShowSettings = "btnShowSettings"
    static let btnShowHelp = "btnShowHelp"
    static let btnStartPauseIdentifier = "btnStartPauseIdentifier"
    static let btnResetIdentifier = "btnResetIdentifier"

    // Labels
    static let lblCounter = "lblCounter"
    static let lblNumberOfCyclesCompleted = "lblNumberOfCyclesCompleted"
    static let lblCycleCounter = "lblCycleCounter"
    static let lblTimerType = "lblTimerType"

    // Counter section
    static let circleFocused = "circleFocused"
    static let circleBreak = "circleBreak"

    // MARK: - Help Screen

    // Labels
    static let lblTechniqueExplanationTitle = "lblTechniqueExplanationTitle"
    static let lblTechniqueExplanation = "lblTechniqueExplanation"

    static let lblFocusExplanationTitle = "lblFocusExplanationTitle"
    static let lblFocusExplanation = "lblFocusExplanation"

    static let lblShortBreakExplanationTitle = "lblShortBreakExplanationTitle"
    static let lblShortBreakExplanation = "lblShortBreakExplanation"

    static let lblLongBreakExplanationTitle = "lblLongBreakExplanationTitle"
    static let lblLongBreakExplanation = "lblLongBreakExplanation"

    static let lblNumberOfCyclesExplanationTitle = "lblNumberOfCyclesExplanationTitle"
    static let lblNumberOfCyclesExplanation = "lblNumberOfCyclesExplanation"
}

enum UserDefaultKeys {
    static let focusedTime = "focusedTime"
    static let shortBreakTime = "shortBreakTime"
    static let remainingTime = "remainingTime"
    static let timestampAppMovedBackground = "timestampAppMovedBackground"
    static let isNotification = "isNotification"
    static let numberOfCycles = "numberOfCycles"
    static let longBreakTime = "longBreakTime"
    static let autoStartToggle = "autoStartToggle"
}

extension Notification.Name {
    static let updateTimerView = Notification.Name("updateTimerView")
}
