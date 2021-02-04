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
    @Published var focusedTime: String

    // MARK: - Initializer
    init(settingsModel: SettingsModelProtocol) {
        focusedTime = String(describing: (settingsModel.getFocusedTime() / 60) == 0 ? 1 : settingsModel.getFocusedTime() / 60)
        self.settingsModel = settingsModel
    }

    // MARK: - Methods
    func saveAndUpdateFocusedTime(time: Int) {
        settingsModel.saveFocusedTime(time: time)
        focusedTime = String(describing: (getFocusedTime() / 60) == 0 ? 1 : getFocusedTime() / 60)
    }

    func getFocusedTime() -> Int {
        settingsModel.getFocusedTime()
    }
}
