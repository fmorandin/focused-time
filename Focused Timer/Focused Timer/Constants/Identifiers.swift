//
//  Identifiers.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/02/21.
//

import Foundation

enum Identifiers {
    // MARK: - Buttons
    static let btnCloseModal = "btnDismissSettings"
    static let btnSaveSettings = "btnSaveSettings"
    static let btnShowSettings = "btnShowSettings"
    static let btnStartPauseIdentifier = "btnStartPauseIdentifier"
    static let btnResetIdentifier = "btnResetIdentifier"

    // MARK: - Labels
    static let lblFocusDuration = "lblFocusDuration"
    static let lblCounter = "lblCounter"

    // MARK: - TextFields
    static let txtFocusedTime = "txtFocusedTime"
}

enum UserDefaultKeys {
    static let focusedTime = "focusedTime"
    static let restTime = "restTime"
}
