//
//  SettingsModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/01/21.
//

import Foundation

// MARK: - Protocols

protocol SettingsModelProtocol {

    /// Function that saves a given time on the UserDefaults
    /// - Parameters:
    ///   - time: an Int that represents the value that will be saved
    ///   - key: the key for the saved value
    func saveTime(time: Int, for keyName: String)

    /// Function that gets the value from the UserDefautls based on a given key
    /// - Parameter key: the key to be retrieved
    func getTime(for keyName: String) -> Int

    /// Function that saves a the amount of cycles on the UserDefaults
    /// - Parameters:
    ///   - cycleNumber: an Int that indicates the number of cycles
    ///   - keyName: the key for the saved value
    func saveNumberOfCycles(numberOfCycles: Int, for keyName: String)

    /// Function that gets the value from the UserDefautls based on a given key
    /// - Parameter keyName: the key to be retrieved
    func getNumberOfCycles(for keyName: String) -> String

    /// Function that saves the value for a toggle
    /// - Parameters:
    ///   - value: the value for the toggle
    ///   - keyName: the key for the saved value
    func saveToggle(value: Bool, for keyName: String)

    /// Function to get the value for a toggle that is saved
    /// - Parameter keyName: the key for the saved value
    func getToggle(for keyName: String) -> Bool

    /// Returns the timer type the user has chosen as the session starting point
    func getStartingTimerType() -> TimerType

    /// Persists the timer type chosen as the session starting point
    func saveStartingTimerType(_ type: TimerType)
}

struct SettingsModel: SettingsModelProtocol {

    // MARK: - Private Variables

    private let repository: StorageRepository

    // MARK: - Initializer

    init(repository: StorageRepository = UserDefaultsRepository()) {
        self.repository = repository
    }

    // MARK: - Methods

    func saveTime(time: Int, for keyName: String) {

        let timeInSeconds = time * 60
        repository.save(timeInSeconds, for: keyName)
    }

    func getTime(for keyName: String) -> Int {

        let totalTime: Int = repository.integer(for: keyName)

        if totalTime != 0 {
            return totalTime
        } else {
            switch keyName {
            case UserDefaultKeys.focusedTime:
                return DefaultValuesConstants.defaultFocusedTime.inSeconds()
            case UserDefaultKeys.shortBreakTime:
                return DefaultValuesConstants.defaultShortBreakTime.inSeconds()
            case UserDefaultKeys.longBreakTime:
                return DefaultValuesConstants.defaultLongBreakTime.inSeconds()
            default:
                return 0
            }
        }
    }

    func saveNumberOfCycles(numberOfCycles: Int, for keyName: String) {

        repository.save(numberOfCycles, for: keyName)
    }

    func getNumberOfCycles(for keyName: String) -> String {

        let numberOfCycles: String = repository.string(for: keyName)
        return numberOfCycles == ""
            ? "\(DefaultValuesConstants.defaultNumberOfCycles.rawValue)"
            : numberOfCycles
    }

    func saveToggle(value: Bool, for keyName: String) {

        repository.save(value, for: keyName)
    }

    func getToggle(for keyName: String) -> Bool {

        repository.bool(for: keyName)
    }

    func getStartingTimerType() -> TimerType {

        let rawValue: String = repository.string(for: UserDefaultKeys.startingTimerType)
        return TimerType(rawValue: rawValue) ?? .focused
    }

    func saveStartingTimerType(_ type: TimerType) {

        repository.save(type.rawValue, for: UserDefaultKeys.startingTimerType)
    }
}
