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
}
