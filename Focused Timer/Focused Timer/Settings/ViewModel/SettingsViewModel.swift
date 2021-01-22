//
//  SettingsViewModel.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 10/01/21.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {

    // MARK: - Private Variables
    private let settingsModel = SettingsModel()

    func saveTotalTime(time: String) {
        settingsModel.saveTotalTime(time: time)
    }

    func getTotalTime() -> Int {
        settingsModel.getTotalTime()
    }
}
