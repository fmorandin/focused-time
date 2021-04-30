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
    private let timerLimits = 5
    private let numberOfCyclesLimits = 2

    // MARK: - Published Variables

    @Published var focusedTime: String = "" {
        didSet {
            if focusedTime.count > timerLimits {
                focusedTime = String(focusedTime.prefix(timerLimits))
            }
        }
    }
    @Published var restTime: String = "" {
        didSet {
            if restTime.count > timerLimits {
                restTime = String(restTime.prefix(timerLimits))
            }
        }
    }
    @Published var cycleTotal: String = "" {
        didSet {
            if cycleTotal.count > numberOfCyclesLimits {
                cycleTotal = String(cycleTotal.prefix(numberOfCyclesLimits))
            }
        }
    }
    @Published var longBreak: String = "" {
        didSet {
            if longBreak.count > timerLimits {
                longBreak = String(longBreak.prefix(timerLimits))
            }
        }
    }
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

    /// Saves a timer based on a given key
    /// - Parameters:
    ///   - keyName: the key name of the value that needs to be saved
    ///   - value: the value to be saved
    func saveTime(for keyName: String, value: Int) {
        value > 0 ?
            settingsModel.saveTime(time: value, for: keyName) :
            debugPrint("Value \(value) for key \(keyName) should be positve.")
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

        numberOfCycles > 0 ?
            settingsModel.saveCycleTotal(cycleNumber: numberOfCycles, for: UserDefaultKeys.cycleTotal) :
            debugPrint("The value \(numberOfCycles) for the number of cycles should be positive.")
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
