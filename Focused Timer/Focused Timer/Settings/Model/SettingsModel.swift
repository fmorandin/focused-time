//
//  SettingsModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/01/21.
//

import Foundation

protocol SettingsModelProtocol {
    func saveFocusedTime(time: Int)
    func getFocusedTime() -> Int
}

struct SettingsModel: SettingsModelProtocol {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Methods
    func saveFocusedTime(time: Int) {
        let timeInSeconds = time * 60
        defaults.set(timeInSeconds, forKey: UserDefaultKeys.focusedTiem)
    }

    func getFocusedTime() -> Int {
        let totalTime = defaults.integer(forKey: UserDefaultKeys.focusedTiem)
        return totalTime != 0 ? totalTime : 1
    }
    
}
