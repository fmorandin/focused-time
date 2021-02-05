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
        let time = settingsModel.getTime(for: UserDefaultKeys.focusedTime)
        let timeInMinutes = time / 60
        focusedTime = String(describing: timeInMinutes == 0 ? 1 : timeInMinutes)
        self.settingsModel = settingsModel
    }

    // MARK: - Methods
    func saveAndUpdateFocusedTime(time: Int) {
        settingsModel.saveTime(time: time, for: UserDefaultKeys.focusedTime)
        let time = getFocusedTime(for: UserDefaultKeys.focusedTime)
        let timeInMinutes = time / 60
        focusedTime = String(describing: (timeInMinutes) == 0 ? 1 : timeInMinutes)
    }

    func getFocusedTime(for key: String) -> Int {
        settingsModel.getTime(for: key)
    }
}
