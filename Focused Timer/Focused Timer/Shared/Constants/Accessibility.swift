//
//  Accessibility.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/02/21.
//

import SwiftUI

enum Accessibility {

    // MARK: - Identifiers

    enum Identifiers {

        // MARK: - Generic

        static let lblAppVersion = "lblAppVersion"
        static let btnShareApp = "btnShareApp"

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
        static let tgPlaySounds = "tgPlaySounds"
        static let tgKeepScreenOn = "tgKeepScreenOn"
        static let lblKeepScreenOnDisclaimer = "lblKeepScreenOnDisclaimer"

        // Labels
        static let lblFocusDuration = "lblFocusDuration"
        static let lblShortBreakDuration = "lblShortBreakDuration"
        static let lblNumberOfCycles = "lblNumberOfCycles"
        static let lblLongBreakDuration = "lblLongBreakDuration"
        static let lblAutoStart = "lblAutoStart"
        static let lblPlaySounds = "lblPlaySounds"
        static let lblKeepScreenOn = "lblKeepScreenOn"

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
}
