//
//  Translation.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/02/21.
//

import SwiftUI

enum Translation {

    // MARK: - Generic

    nonisolated(unsafe) static let warningAlertTitle = LocalizedStringKey("warningAlertTitle")
    nonisolated(unsafe) static let appVersionTitle = LocalizedStringKey("appVersionTitle")
    nonisolated(unsafe) static let shareAppTitle = LocalizedStringKey("shareAppTitle")
    nonisolated(unsafe) static let shareAppMessage = LocalizedStringKey("shareAppMessage")

    nonisolated(unsafe) static let dismissModalButton = LocalizedStringKey("dismissModelButton")

    // MARK: - Settings Screen

    nonisolated(unsafe) static let settingsFocusDuration = LocalizedStringKey("settingsFocusDuration")
    nonisolated(unsafe) static let settingsShortBreakDuration = LocalizedStringKey("settingsShortBreakDuration")
    nonisolated(unsafe) static let settingsNumberOfCyclesTotal = LocalizedStringKey("settingsNumberOfCyclesTotal")
    nonisolated(unsafe) static let settingsLongBreakDuration = LocalizedStringKey("settingsLongBreakDuration")

    nonisolated(unsafe) static let settingsSectionTimersName = LocalizedStringKey("settingsSectionTimersName")
    nonisolated(unsafe) static let settingsSectionAppName = LocalizedStringKey("settingsSectionAppName")

    nonisolated(unsafe) static let settingsAutoStart = LocalizedStringKey("settingsAutoStart")
    nonisolated(unsafe) static let settingsPlayTimerSounds = LocalizedStringKey("settingsPlayTimerSounds")
    nonisolated(unsafe) static let settingsKeepScreenOn = LocalizedStringKey("settingsKeepScreenOn")
    nonisolated(unsafe) static let settingsKeepScreenOnDisclaimer = LocalizedStringKey("settingsKeepScreenOnDisclaimer")

    nonisolated(unsafe) static let settingsWarnReloadMessage = LocalizedStringKey("settingsWarnReloadMessage")

    nonisolated(unsafe) static let resetSettingsDefaultValue = LocalizedStringKey("resetSettingsDefaultValue")
    nonisolated(unsafe) static let resetSettingsAlertTitle = LocalizedStringKey("resetSettingsAlertTitle")
    nonisolated(unsafe) static let resetSettingsAlertMessage = LocalizedStringKey("resetSettingsAlertMessage")

    // MARK: - Timer Screen

    nonisolated(unsafe) static let timerViewOpenSettingsModalButton =
        LocalizedStringKey("timerViewOpenSettingsModalButton")
    nonisolated(unsafe) static let timerViewOpenHelpModalButton =
        LocalizedStringKey("timerViewOpenHelpModalButton")

    nonisolated(unsafe) static let playTimer = LocalizedStringKey("playTimer")
    nonisolated(unsafe) static let pauseTimer = LocalizedStringKey("pauseTimer")
    nonisolated(unsafe) static let resetTimer = LocalizedStringKey("resetTimer")
    nonisolated(unsafe) static let resumeTimer = LocalizedStringKey("resumeTimer")
    nonisolated(unsafe) static let cycleCounter = LocalizedStringKey("cycleCounter")

    nonisolated(unsafe) static let focusName = LocalizedStringKey("focusName")
    nonisolated(unsafe) static let shortBreakName = LocalizedStringKey("shortBreakName")
    nonisolated(unsafe) static let longBreakName = LocalizedStringKey("longBreakName")

    // MARK: - Notification

    nonisolated(unsafe) static let notificationTitle = LocalizedStringKey("notificationTitle")
    nonisolated(unsafe) static let notificationBody = LocalizedStringKey("notificationBody")

    // MARK: - Help Screen

    nonisolated(unsafe) static let techniqueExplanationTitle = LocalizedStringKey("techniqueExplanationTitle")
    nonisolated(unsafe) static let techniqueExplanation = LocalizedStringKey("techniqueExplanation")

    nonisolated(unsafe) static let focusExplanationTitle = LocalizedStringKey("focusExplanationTitle")
    nonisolated(unsafe) static let focusExplanation = LocalizedStringKey("focusExplanation")

    nonisolated(unsafe) static let shortBreakExplanationTitle = LocalizedStringKey("shortBreakExplanationTitle")
    nonisolated(unsafe) static let shortBreakExplanation = LocalizedStringKey("shortBreakExplanation")

    nonisolated(unsafe) static let longBreakExplanationTitle = LocalizedStringKey("longBreakExplanationTitle")
    nonisolated(unsafe) static let longBreakExplanation = LocalizedStringKey("longBreakExplanation")

    nonisolated(unsafe) static let numberOfCyclesExplanationTitle = LocalizedStringKey("numberOfCyclesExplanationTitle")
    nonisolated(unsafe) static let numberOfCyclesExplanation = LocalizedStringKey("numberOfCyclesExplanation")
}
