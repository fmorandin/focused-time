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

    private let settingsModel: any SettingsModelProtocol
    private let shareService: any ShareService
    private let notificationCenter: any UserNotificationCenterProtocol
    private let alarmAuthorizationChecker: any AlarmAuthorizationChecking
    private let urlOpener: any URLOpening
    private let liveActivityManager: any LiveActivityManaging

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
    var isAlarmEnabled: Bool = true
    var isAlarmDeniedBySystem: Bool = false
    var areLiveActivitiesEnabled: Bool = true
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
        settingsModel: any SettingsModelProtocol,
        shareService: any ShareService = UIKitShareService(),
        notificationCenter: any UserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        alarmAuthorizationChecker: any AlarmAuthorizationChecking = AlarmKitAuthorizationChecker(),
        urlOpener: any URLOpening = UIApplication.shared,
        liveActivityManager: any LiveActivityManaging = LiveActivityManager.shared
    ) {
        Self.logger.notice("🛠 Initializing Settings View Model.")

        self.settingsModel = settingsModel
        self.shareService = shareService
        self.notificationCenter = notificationCenter
        self.alarmAuthorizationChecker = alarmAuthorizationChecker
        self.urlOpener = urlOpener
        self.liveActivityManager = liveActivityManager

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
        isAlarmEnabled = settingsModel.getToggle(for: UserDefaultKeys.enableAlarm)
        areLiveActivitiesEnabled = settingsModel.getLiveActivitiesEnabled()
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

    /// Saves the alarm-enabled toggle. Enabling the alarm disables notifications (mutually exclusive).
    func saveAlarmEnabled(_ value: Bool) {

        isAlarmEnabled = value
        saveToggles(for: UserDefaultKeys.enableAlarm, value: value)
        if value {
            isNotificationsEnabled = false
            saveToggles(for: UserDefaultKeys.enableNotifications, value: false)
        }
    }

    /// Saves the notifications-enabled toggle. Enabling notifications disables the alarm (mutually exclusive).
    func saveNotificationsEnabled(_ value: Bool) {

        isNotificationsEnabled = value
        saveToggles(for: UserDefaultKeys.enableNotifications, value: value)
        if value {
            isAlarmEnabled = false
            saveToggles(for: UserDefaultKeys.enableAlarm, value: false)
        }
    }

    /// Saves the auto-start toggle. Enabling auto-start disables the alarm and restores notifications.
    func saveAutoStartEnabled(_ value: Bool) {

        isAutoStartEnabled = value
        saveToggles(for: UserDefaultKeys.autoStartToggle, value: value)
        if value {
            isAlarmEnabled = false
            saveToggles(for: UserDefaultKeys.enableAlarm, value: false)
            isNotificationsEnabled = true
            saveToggles(for: UserDefaultKeys.enableNotifications, value: true)
        }
    }

    /// Saves the Live Activity preference and applies it to the current timer immediately.
    func saveLiveActivitiesEnabled(_ value: Bool) {

        areLiveActivitiesEnabled = value
        settingsModel.saveLiveActivitiesEnabled(value)
        liveActivityManager.handle(.preferenceChanged(value))
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
        saveToggles(for: UserDefaultKeys.enableAlarm, value: false)
        saveLiveActivitiesEnabled(true)
        saveNumberOfCycles(DefaultValuesConstants.defaultNumberOfCycles.rawValue)
        saveStartingTimerType(.focused)
        saveAppearanceMode(.system)

        populateAllFieldsSavedValues()
    }

    /// Checks the system-level notification authorization status and updates `isNotificationsDeniedBySystem`.
    /// When denied, forces the notifications toggle off so the UI reflects the system state.
    func checkNotificationAuthorizationStatus() async {

        let status = await notificationCenter.getAuthorizationStatus()
        isNotificationsDeniedBySystem = status == .denied
        if isNotificationsDeniedBySystem {
            isNotificationsEnabled = false
            saveToggles(for: UserDefaultKeys.enableNotifications, value: false)
        }
    }

    /// Checks whether AlarmKit permission has been denied by the system and updates `isAlarmDeniedBySystem`.
    /// When denied, forces the alarm toggle off so the UI reflects the system state.
    func checkAlarmAuthorizationStatus() {

        isAlarmDeniedBySystem = alarmAuthorizationChecker.isDeniedBySystem
        if isAlarmDeniedBySystem {
            isAlarmEnabled = false
            saveToggles(for: UserDefaultKeys.enableAlarm, value: false)
        }
    }

    /// Opens the iOS Settings app so the user can restore alarm permission.
    func openAlarmSettings() async {

        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            Self.logger.error("Failed to create the app settings URL.")
            return
        }
        await urlOpener.open(settingsURL)
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
