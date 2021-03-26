//
//  Translation.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/02/21.
//

import SwiftUI

enum Translation {
    // MARK: - Settings Screen

    static let settingsFocusDuration = LocalizedStringKey("settingsFocusDuration")
    static let settingsRestDuration = LocalizedStringKey("settingsRestDuration")
    static let settingsCyclesTotal = LocalizedStringKey("settingsCycleTotal")
    static let settingsLongBreak = LocalizedStringKey("settingsLongBreak")

    // MARK: - Timer Screen

    static let playTimer = LocalizedStringKey("playTimer")
    static let pauseTimer = LocalizedStringKey("pauseTimer")
    static let resetTimer = LocalizedStringKey("resetTimer")
    static let cycleCounter = LocalizedStringKey("cycleCounter")

    static let focusName = LocalizedStringKey("focusName")
    static let restName = LocalizedStringKey("restName")
    static let longBreakName = LocalizedStringKey("longBreakName")

    // MARK: - Notification

    static let notificationTitle = LocalizedStringKey("notificationTitle")
    static let notificationBody = LocalizedStringKey("notificationBody")

    // MARK: - Help Screen

    static let techniqueExplanationTitle = LocalizedStringKey("techniqueExplanationTitle")
    static let techniqueExplanation = LocalizedStringKey("techniqueExplanation")

    static let focusExplanationTitle = LocalizedStringKey("focusExplanationTitle")
    static let focusExplanation = LocalizedStringKey("focusExplanation")

    static let restExplanationTitle = LocalizedStringKey("restExplanationTitle")
    static let restExplanation = LocalizedStringKey("restExplanantion")

    static let longBreakExplanationTitle = LocalizedStringKey("longBreakExplanationTitle")
    static let longBreakExplanation = LocalizedStringKey("longBreakExplanation")

    static let numberOfCyclesExplanationTitle = LocalizedStringKey("numberOfCyclesExplanationTitle")
    static let numberOfCyclesExplanation = LocalizedStringKey("numberOfCyclesExplanation")
}
