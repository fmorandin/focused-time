//
//  SettingsViewModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 10/01/21.
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {

    // MARK: - Private Variables

    private let settingsModel: SettingsModelProtocol

    // MARK: - Published Variables

    @Published var focusedTime: String
    @Published var restTime: String
    @Published var cycleTotal: String
    @Published var longBreak: String
    @Published var autoStart: Bool

    // MARK: - Initializer

    init(settingsModel: SettingsModelProtocol) {
        self.settingsModel = settingsModel

        let focusedTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.focusedTime)
        let focusedTimeInMinutes = focusedTimeInSeconds / 60
        self.focusedTime = String(describing: focusedTimeInMinutes == 0 ? 1 : focusedTimeInMinutes)

        let restTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.restTime)
        let restTimeInMinutes = restTimeInSeconds / 60
        self.restTime = String(describing: restTimeInMinutes == 0 ? 1 : restTimeInMinutes)

        self.cycleTotal = settingsModel.getCycleTotal(for: UserDefaultKeys.cycleTotal)

        let longBreakInSeconds = settingsModel.getTime(for: UserDefaultKeys.longBreak)
        let longBrakInMinutes = longBreakInSeconds / 60
        self.longBreak = String(describing: longBrakInMinutes == 0 ? 1 : longBrakInMinutes)

        self.autoStart = settingsModel.getToggle(for: UserDefaultKeys.autoStart)
    }

    // MARK: - Methods

    /// Method that saves the values of the timers from the settings screen.
    /// After saving the fields, the values are updated in order to be able to be displayed on the screen
    /// - Parameters:
    ///   - focusedIime: the value for the focused time
    ///   - restTime: the value for the rest time
    ///   - longBreak: the value for the long break
    func saveAndUpdateTimes(focusedIime: Int, restTime: Int, longBreak: Int) {
        settingsModel.saveTime(time: focusedIime, for: UserDefaultKeys.focusedTime)
        settingsModel.saveTime(time: restTime, for: UserDefaultKeys.restTime)
        settingsModel.saveTime(time: longBreak, for: UserDefaultKeys.longBreak)

        self.focusedTime = String(describing: getTimeInMinutes(for: UserDefaultKeys.focusedTime))
        self.restTime = String(describing: getTimeInMinutes(for: UserDefaultKeys.restTime))
        self.longBreak = String(describing: getTimeInMinutes(for: UserDefaultKeys.longBreak))
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
        settingsModel.saveCycleTotal(cycleNumber: numberOfCycles, for: UserDefaultKeys.cycleTotal)

        cycleTotal = String(describing: settingsModel.getCycleTotal(for: UserDefaultKeys.cycleTotal))
    }

    /// Returns the number of the cycles
    /// - Parameter keyName: the key name to be retrieved
    /// - Returns: the number of the cycles
    func getNumberOfCycles(for keyName: String) -> Int {
        Int(settingsModel.getCycleTotal(for: UserDefaultKeys.cycleTotal)) ?? 0
    }

    /// Function to save the autoStart toggle value. Can be easilly changed to be more generic if necessary
    /// - Parameter autoStart: the value of the toggle
    func saveToggles(autoStart: Bool) {
        settingsModel.saveToggle(value: autoStart, for: UserDefaultKeys.autoStart)

        self.autoStart = settingsModel.getToggle(for: UserDefaultKeys.autoStart)
    }

    /// Function that retrieves the boolean valeu for a given key
    /// - Parameter keyName: the name of the key to be returned
    /// - Returns: the value of the key
    func getSavedToggles(for keyName: String) -> Bool {
        settingsModel.getToggle(for: keyName)
    }
}
