//
//  SettingsModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/01/21.
//

import Foundation

protocol SettingsModelProtocol {
    func saveTotalTime(time: Int)
    func getTotalTime() -> Int
}

struct SettingsModel: SettingsModelProtocol {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Methods
    func saveTotalTime(time: Int) {
        let timeInSeconds = time * 60
        defaults.set(timeInSeconds, forKey: "totalTime")
    }

    func getTotalTime() -> Int {
        let totalTime = defaults.integer(forKey: "totalTime")
        return totalTime != 0 ? totalTime : 1
    }
    
}
