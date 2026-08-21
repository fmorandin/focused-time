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
        static let btnResetSettingsDefault = "btnResetSettingsDefault"

        // TextFields
        static let txtFocusedTime = "txtFocusedTime"
        static let txtShortBreakTime = "txtShortBreakTime"
        static let txtNumberOfCycles = "txtNumberOfCycles"
        static let txtLongBreakTime = "txtLongBreakTime"

        // Pickers
        static let pkAppearanceMode = "pkAppearanceMode"

        // Toggles
        static let tgAutoStart = "tgAutoStart"
        static let tgPlaySounds = "tgPlaySounds"
        static let tgKeepScreenOn = "tgKeepScreenOn"
        static let tgEnableAlarm = "tgEnableAlarm"
        static let lblAlarmDeniedMessage = "lblAlarmDeniedMessage"
        static let btnOpenAlarmSettings = "btnOpenAlarmSettings"
        static let lblAlarmAutoStartConflictMessage = "lblAlarmAutoStartConflictMessage"
        static let tgEnableNotifications = "tgEnableNotifications"
        static let lblKeepScreenOnDisclaimer = "lblKeepScreenOnDisclaimer"
        static let lblNotificationsDeniedMessage = "lblNotificationsDeniedMessage"
        static let btnOpenNotificationsSettings = "btnOpenNotificationsSettings"

        // Focus
        static let lblFocusIntegration = "lblFocusIntegration"
        static let lblFocusIntegrationDescription = "lblFocusIntegrationDescription"

        // Labels
        static let lblFocusDuration = "lblFocusDuration"
        static let lblShortBreakDuration = "lblShortBreakDuration"
        static let lblNumberOfCycles = "lblNumberOfCycles"
        static let lblLongBreakDuration = "lblLongBreakDuration"

        static let lblWarnReloadMessage = "lblWarnReloadMessage"
        static let lblInvalidNumberMessage = "lblInvalidNumberMessage"

        // MARK: - Tab Bar

        static let tabTimer    = "tabTimer"
        static let tabSettings = "tabSettings"
        static let tabHelp     = "tabHelp"

        // MARK: - Timer Screen

        // Buttons
        static let pkStartingTimerType = "pkStartingTimerType"

        static let btnStartPauseIdentifier = "btnStartPauseIdentifier"
        static let btnResetIdentifier = "btnResetIdentifier"

        // Labels
        static let lblCounter = "lblCounter"
        static let lblNumberOfCyclesCompleted = "lblNumberOfCyclesCompleted"
        static let lblCycleCounter = "lblCycleCounter"
        static let lblTimerType = "lblTimerType"

        // MARK: - Help Screen

        // Labels
        static let lblTechniqueExplanation = "lblTechniqueExplanation"
        static let lblFocusExplanation = "lblFocusExplanation"
        static let lblShortBreakExplanation = "lblShortBreakExplanation"
        static let lblLongBreakExplanation = "lblLongBreakExplanation"
        static let lblNumberOfCyclesExplanation = "lblNumberOfCyclesExplanation"

        // MARK: - What's New Screen

        // Buttons
        static let btnWhatsNewDismiss = "btnWhatsNewDismiss"
        static let btnSettingsChangelog = "btnSettingsChangelog"

        // Labels
        static let lblWhatsNewTitle = "lblWhatsNewTitle"
        static let lblWhatsNewVersion = "lblWhatsNewVersion"
        static let lblChangelogRelease = "lblChangelogRelease"
        static let lblChangelogEmpty = "lblChangelogEmpty"
    }
}
