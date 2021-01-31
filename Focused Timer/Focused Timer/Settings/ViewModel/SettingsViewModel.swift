//
//  SettingsViewModel.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 10/01/21.
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {

    // MARK: - Private Variables
    private let settingsModel = SettingsModel()

    // MARK: - Published Variables
    @Published var totalTime: String

    init() {
        totalTime = String(describing: settingsModel.getTotalTime())
    }

    func saveTotalTime(time: String) {
        settingsModel.saveTotalTime(time: time)
    }
}
