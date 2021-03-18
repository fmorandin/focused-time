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
    func saveCycleTotal(cycleNumber: Int, for keyName: String)

    /// Function that gets the value from the UserDefautls based on a given key
    /// - Parameter keyName: the key to be retrieved
    func getCycleTotal(for keyName: String) -> String
}

struct SettingsModel: SettingsModelProtocol {

    // MARK: - Private Variables

    private let defaults = UserDefaults.standard

    // MARK: - Methods

    func saveTime(time: Int, for keyName: String) {
        let timeInSeconds = time * 60
        defaults.set(timeInSeconds, forKey: keyName)
    }

    func getTime(for keyName: String) -> Int {
        let totalTime = defaults.integer(forKey: keyName)
        return totalTime != 0 ? totalTime : 1
    }

    func saveCycleTotal(cycleNumber: Int, for keyName: String) {
        defaults.setValue(cycleNumber, forKey: keyName)
    }

    func getCycleTotal(for keyName: String) -> String {
        defaults.string(forKey: keyName) ?? "0"
    }
}
