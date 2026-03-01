//
//  SettingsViewModel.swift
//  Focused Timer
//

import Foundation
import SwiftUI
import os

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SettingsViewModel.self)
    )

    private let settingsModel: SettingsModelProtocol
    private let shareService: ShareService

    // Maximum number of characters for the fields
    let timerLimits = 3
    let numberOfCyclesLimits = 2

    // MARK: - Published Variables

    @Published var focusedTime: String = ""
    @Published var shortBreakTime: String = ""
    @Published var cycleTotal: String = ""
    @Published var longBreak: String = ""
    @Published var isAutoStartEnabled: Bool = false
    @Published var isPlaySoundEnabled: Bool = true
    @Published var keepScreenOn: Bool = false

    // If the timer is running and the user changes something the timer should be updated
    @Published var shouldUpdateTimerView = false

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
        shareService: ShareService = UIKitShareService()
    ) {
        Self.logger.notice("🛠 Initializing Settings View Model.")

        self.settingsModel = settingsModel
        self.shareService = shareService

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
        saveNumberOfCycles(DefaultValuesConstants.defaultNumberOfCycles.rawValue)

        populateAllFieldsSavedValues()
    }

    /// Triggers the system share sheet for the app
    func shareSheet() {

        Self.logger.notice("📤 Opening share sheet.")
        shareService.shareApp()
    }
}
