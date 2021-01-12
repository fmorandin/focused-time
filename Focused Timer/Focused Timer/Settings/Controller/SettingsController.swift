//
//  SettingsController.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 10/01/21.
//

import Foundation
import Combine

class SettingsController: ObservableObject {

    private let defaults = UserDefaults.standard

    func saveTotalTime(time: String) {
        defaults.set(time, forKey: "totalTime")
    }

    func getTotalTime() -> Int {
        defaults.integer(forKey: "totalTime")
    }
}
