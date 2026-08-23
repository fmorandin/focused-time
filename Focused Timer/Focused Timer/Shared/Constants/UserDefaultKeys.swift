//
//  UserDefaultKeys.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 19/05/21.
//

import Foundation

enum UserDefaultKeys {

    static let focusedTime = "focusedTime"
    static let shortBreakTime = "shortBreakTime"
    static let remainingTime = "remainingTime"
    static let timestampAppMovedBackground = "timestampAppMovedBackground"
    static let isNotification = "isNotification"
    static let numberOfCycles = "numberOfCycles"
    static let longBreakTime = "longBreakTime"
    static let autoStartToggle = "autoStartToggle"
    static let playTimerSounds = "playTimerSounds"
    static let keepScreenOn = "keepScreenOn"
    static let enableNotifications = "enableNotifications"
    static let startingTimerType = "startingTimerType"
    static let appearanceMode = "appearanceMode"
    static let enableAlarm = "enableAlarm"
    static let timerTypeBackground = "timerTypeBackground"
    static let completedCyclesBackground = "completedCyclesBackground"
    static let previousPhaseWasFocusBackground = "previousPhaseWasFocusBackground"

    // MARK: - Onboarding

    /// Present after the first opening of a fresh installation.
    static let onboardingHasBeenShown = "onboardingHasBeenShown"

    // MARK: - What's New

    /// Highest release already shown to the user, as a `major.minor.patch` string.
    static let whatsNewLastSeenVersion = "whatsNewLastSeenVersion"

    /// Set while UI testing so the modal never interrupts an automated run.
    static let whatsNewSuppressed = "whatsNewSuppressed"
}
