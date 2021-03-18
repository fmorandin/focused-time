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
    static let btnSaveSettings = "btnSaveSettings"

    // TextFields
    static let txtFocusedTime = "txtFocusedTime"
    static let txtRestTime = "txtRestTime"
    static let txtCycleTotal = "txtCycleTotal"

    // Labels
    static let lblFocusDuration = "lblFocusDuration"
    static let lblRestDuration = "lblRestDuration"
    static let lblCycleTotal = "lblCycleTotal"

    // MARK: - Timer Screen

    // Buttons
    static let btnShowSettings = "btnShowSettings"
    static let btnShowHelp = "btnShowHelp"
    static let btnStartPauseIdentifier = "btnStartPauseIdentifier"
    static let btnResetIdentifier = "btnResetIdentifier"

    // Labels
    static let lblCounter = "lblCounter"
    static let lblNumberOfCyclesCompleted = "lblNumberOfCyclesCompleted"

    // Counter section
    static let circleFocused = "circleFocused"
    static let circleRest = "circleRest"
}

enum UserDefaultKeys {
    static let focusedTime = "focusedTime"
    static let restTime = "restTime"
    static let remainingTime = "remainingTime"
    static let timestampAppMovedBackground = "timestampAppMovedBackground"
    static let isNotification = "isNotification"
    static let cycleTotal = "cycleTotal"
}
