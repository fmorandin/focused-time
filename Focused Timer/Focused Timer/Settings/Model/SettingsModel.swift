//
//  SettingsModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/01/21.
//

import Foundation

struct SettingsModel {

    private let defaults = UserDefaults.standard

    func saveTotalTime(time: String) {
        defaults.set(time, forKey: "totalTime")
    }

    func getTotalTime() -> Int {
        defaults.integer(forKey: "totalTime")
    }
    
}
