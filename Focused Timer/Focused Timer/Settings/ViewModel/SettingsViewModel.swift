//
//  SettingsViewModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 10/01/21.
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

    // Maximum number of characters for the fields
    let timerLimits = 3
    let numberOfCyclesLimits = 2

    private let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    private var window: UIWindow?

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

    init(settingsModel: SettingsModelProtocol) {

        Self.logger.notice("🛠 Initializing Settings View Model.")

        self.settingsModel = settingsModel

        populateAllFieldsSavedValues()

        window = windowScene?.windows.first
    }

    // MARK: - Private Functions

    /// Function that populates all the fields with the saved values
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

    /// Saves a timer based on a given key
    /// - Parameters:
    ///   - keyName: the key name of the value that needs to be saved
    ///   - value: the value to be saved
    func saveTime(for keyName: String, value: Int) {

        guard value > 0 else {
            Self.logger.error("🙅🏻‍♂️ Value \(value) for key \(keyName) should be positive.")
            return
        }

        settingsModel.saveTime(time: value, for: keyName)

    }

    /// Function that returns the value in seconds for a saved timer
    /// - Parameter keyName: the key name that needs to be retrieved
    /// - Returns: the value of the timer in seconds
    func getTimeInMinutes(for keyName: String) -> Int {

        let timeInMinutes = settingsModel.getTime(for: keyName) / 60
        return timeInMinutes == 0 ? 1 : timeInMinutes
    }

    /// Method that saves the number of cycles
    /// - Parameter numberOfCycles: the number of cycles that will be saved
    func saveNumberOfCycles(_ numberOfCycles: Int) {

        guard numberOfCycles > 0 else {
            Self.logger.error(
                "🙅🏻‍♂️ Value \(numberOfCycles) for key \(UserDefaultKeys.numberOfCycles) should be positive."
            )
            return
        }

        settingsModel.saveNumberOfCycles(numberOfCycles: numberOfCycles, for: UserDefaultKeys.numberOfCycles)
    }

    /// Returns the number of the cycles
    /// - Parameter keyName: the key name to be retrieved
    /// - Returns: the number of the cycles
    func getNumberOfCycles(for keyName: String) -> Int {

        Int(settingsModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)) ?? 0
    }

    /// Function to save the autoStart toggle value. Can be easilly changed to be more generic if necessary
    /// - Parameters:
    ///   - keyName: the key name of the value that needs to be saved
    ///   - value: the value of the toggle
    func saveToggles(for keyName: String, value: Bool) {

        settingsModel.saveToggle(value: value, for: keyName)
    }

    /// Function that retrieves the boolean valeu for a given key
    /// - Parameter keyName: the name of the key to be returned
    /// - Returns: the value of the key
    func getSavedToggles(for keyName: String) -> Bool {

        settingsModel.getToggle(for: keyName)
    }

    /// Function that will reset the values to the default ones.
    /// This saves again all the fields with the default values and then populate
    /// all the fields in the screen again
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

    /// Function that defines what is the text and the link used in the share
    func shareSheet() {

        Self.logger.notice("📤 Opening share sheet.")

        let appStoreUrl = URL(string: "https://apps.apple.com/us/app/focused-timer/id1563481123")!
        let shareMessage = NSString.localizedUserNotificationString(forKey: "shareAppMessage", arguments: nil)

        let activityVC = UIActivityViewController(
            activityItems: [shareMessage, appStoreUrl],
            applicationActivities: nil
        )

        window?.rootViewController?.present(
            activityVC,
            animated: true,
            completion: nil
        )
    }
}
