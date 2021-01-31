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
    private let settingsModel: SettingsModelProtocol

    // MARK: - Published Variables
    @Published var totalTime: String

    // MARK: - Initializer
    init(settingsModel: SettingsModelProtocol) {
        totalTime = String(describing: settingsModel.getTotalTime())
        self.settingsModel = settingsModel
    }

    // MARK: - Methods
    func saveAndUpdateTotalTimeValue(time: String) {
        settingsModel.saveTotalTime(time: time)
        totalTime = String(describing: getTotalTime())
    }

    func getTotalTime() -> Int {
        settingsModel.getTotalTime()
    }
}
