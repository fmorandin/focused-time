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
}
