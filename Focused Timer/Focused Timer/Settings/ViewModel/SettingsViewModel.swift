//
//  SettingsViewModel.swift
//  Focused Timer
//

import Foundation
import Observation
import SwiftUI
import UIKit
import UserNotifications
import os

// MARK: - URLOpening protocol

/// Abstracts UIApplication.open(_:) so SettingsViewModel is testable without a live UIApplication.
@MainActor
protocol URLOpening {
    @discardableResult
    func open(_ targetURL: URL) async -> Bool
}

extension UIApplication: URLOpening {
    func open(_ targetURL: URL) async -> Bool {
        await open(targetURL, options: [:])
    }
}

// MARK: - SettingsViewModel

@MainActor
@Observable
final class SettingsViewModel {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SettingsViewModel.self)
    )

    private let settingsModel: SettingsModelProtocol
    private let shareService: ShareService
    private let notificationCenter: UserNotificationCenterProtocol
    private let urlOpener: URLOpening

    // Maximum number of characters for the fields
    let timerLimits = 3
    let numberOfCyclesLimits = 2

    // MARK: - Observable Variables

    var focusedTime: String = ""
    var shortBreakTime: String = ""
    var cycleTotal: String = ""
    var longBreak: String = ""
    var isAutoStartEnabled: Bool = false
    var isPlaySoundEnabled: Bool = true
    var keepScreenOn: Bool = false
    var isNotificationsEnabled: Bool = true
    var isNotificationsDeniedBySystem: Bool = false
    var startingTimerType: TimerType = .focused
    var appearanceMode: AppearanceMode = .system

    // If the timer is running and the user changes something the timer should be updated
    var shouldUpdateTimerView = false

    var appVersionNumber: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            Self.logger.error("Missing CFBundleShortVersionString in Info.plist.")
            return "0"
        }

        return version
    }

    // MARK: - Initializer

    init(
        settingsModel: SettingsModelProtocol,
        shareService: ShareService = UIKitShareService(),
        notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        urlOpener: URLOpening = UIApplication.shared
    ) {
        Self.logger.notice("🛠 Initializing Settings View Model.")

        self.settingsModel = settingsModel
        self.shareService = shareService
        self.notificationCenter = notificationCenter
        self.urlOpener = urlOpener

        populateAllFieldsSavedValues()
    }

    // MARK: - Private Functions

    /// Populates all the fields with the saved values
    private func populateAllFieldsSavedValues() {

        Self.logger.notice("📝 Populating all the fields with the saved values.")

        let focusedTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.focusedTime)
        let focusedTimeInMinutes = focusedTimeInSeconds / 60
        focusedTime = String(describing: focusedTimeInMinutes == 0 ? 1 : focusedTimeInMinutes)

        let shortBreakTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.shortBreakTime)
        let shortBreakTimeInMinutes = shortBreakTimeInSeconds / 60
        shortBreakTime = String(describing: shortBreakTimeInMinutes == 0 ? 1 : shortBreakTimeInMinutes)

        cycleTotal = settingsModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)

        let longBreakInSeconds = settingsModel.getTime(for: UserDefaultKeys.longBreakTime)
        let longBreakInMinutes = longBreakInSeconds / 60
        longBreak = String(describing: longBreakInMinutes == 0 ? 1 : longBreakInMinutes)

        isAutoStartEnabled = settingsModel.getToggle(for: UserDefaultKeys.autoStartToggle)
        isPlaySoundEnabled = settingsModel.getToggle(for: UserDefaultKeys.playTimerSounds)
        keepScreenOn = settingsModel.getToggle(for: UserDefaultKeys.keepScreenOn)
        isNotificationsEnabled = settingsModel.getToggle(for: UserDefaultKeys.enableNotifications)
        startingTimerType = settingsModel.getStartingTimerType()
        appearanceMode = settingsModel.getAppearanceMode()
    }

    // MARK: - Public Functions

    /// Saves a timer based on a given key
    func saveTime(for keyName: String, value: Int) {

        guard value > 0 else {
            Self.logger.error("🙅🏻‍♂️ Value \(value) for key \(keyName) should be positive.")
            return
        }

        settingsModel.saveTime(time: value, for: keyName)
    }

    /// Returns the value in minutes for a saved timer
    func getTimeInMinutes(for keyName: String) -> Int {

        let timeInMinutes = settingsModel.getTime(for: keyName) / 60
        return timeInMinutes == 0 ? 1 : timeInMinutes
    }

    /// Saves the number of cycles
    func saveNumberOfCycles(_ numberOfCycles: Int) {

        guard numberOfCycles > 0 else {
            Self.logger.error(
                "🙅🏻‍♂️ Value \(numberOfCycles) for key \(UserDefaultKeys.numberOfCycles) should be positive."
            )
            return
        }

        settingsModel.saveNumberOfCycles(numberOfCycles: numberOfCycles, for: UserDefaultKeys.numberOfCycles)
    }

    /// Returns the number of cycles
    func getNumberOfCycles(for keyName: String) -> Int {

        Int(settingsModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
    }

    /// Saves a toggle value for the given key
    func saveToggles(for keyName: String, value: Bool) {

        settingsModel.saveToggle(value: value, for: keyName)
    }

    /// Returns the saved value for a toggle key
    func getSavedToggles(for keyName: String) -> Bool {

        settingsModel.getToggle(for: keyName)
    }

    /// Resets all settings to their default values
    func resetToDefault() {

        Self.logger.notice("🔄 Reseting all the items to their default values.")

        saveTime(
            for: UserDefaultKeys.focusedTime,
            value: DefaultValuesConstants.defaultFocusedTime.rawValue
        )
        saveTime(
            for: UserDefaultKeys.shortBreakTime,
            value: DefaultValuesConstants.defaultShortBreakTime.rawValue
        )
        saveTime(
            for: UserDefaultKeys.longBreakTime,
            value: DefaultValuesConstants.defaultLongBreakTime.rawValue
        )
        saveToggles(for: UserDefaultKeys.autoStartToggle, value: false)
        saveToggles(for: UserDefaultKeys.playTimerSounds, value: false)
        saveToggles(for: UserDefaultKeys.keepScreenOn, value: false)
        saveToggles(for: UserDefaultKeys.enableNotifications, value: true)
        saveNumberOfCycles(DefaultValuesConstants.defaultNumberOfCycles.rawValue)
        saveStartingTimerType(.focused)
        saveAppearanceMode(.system)

        populateAllFieldsSavedValues()
    }

    /// Checks the system-level notification authorization status and updates `isNotificationsDeniedBySystem`.
    func checkNotificationAuthorizationStatus() async {

        let status = await notificationCenter.getAuthorizationStatus()
        isNotificationsDeniedBySystem = status == .denied
    }

    /// Opens the iOS Settings app at the Notifications page for this app.
    func openNotificationSettings() async {

        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            Self.logger.error("Failed to create the notification settings URL.")
            return
        }
        await urlOpener.open(settingsURL)
    }

    /// Saves the user's chosen starting timer type and signals that the timer view should update
    func saveStartingTimerType(_ type: TimerType) {

        settingsModel.saveStartingTimerType(type)
        startingTimerType = type
        shouldUpdateTimerView = true
    }

    /// Saves the user's chosen appearance mode
    func saveAppearanceMode(_ mode: AppearanceMode) {

        settingsModel.saveAppearanceMode(mode)
        appearanceMode = mode
    }

    /// Triggers the system share sheet for the app
    func shareSheet() {

        Self.logger.notice("📤 Opening share sheet.")
        shareService.shareApp()
    }
}
