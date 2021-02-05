//
//  SettingsModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/01/21.
//

import Foundation

protocol SettingsModelProtocol {
    func saveTime(time: Int, for key: String)
    func getTime(for key: String) -> Int
}

struct SettingsModel: SettingsModelProtocol {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Methods
    func saveTime(time: Int, for key: String) {
        let timeInSeconds = time * 60
        defaults.set(timeInSeconds, forKey: key)
    }

    func getTime(for key: String) -> Int {
        let totalTime = defaults.integer(forKey: key)
        return totalTime != 0 ? totalTime : 1
    }
    
}
