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
    @Published var restTime: String

    // MARK: - Initializer

    init(settingsModel: SettingsModelProtocol) {
        let focusedTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.focusedTime)
        let focusedTimeInMinutes = focusedTimeInSeconds / 60
        self.focusedTime = String(describing: focusedTimeInMinutes == 0 ? 1 : focusedTimeInMinutes)

        let restTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.restTime)
        let restTimeInMinutes = restTimeInSeconds / 60
        self.restTime = String(describing: restTimeInMinutes == 0 ? 1 : restTimeInMinutes)

        self.settingsModel = settingsModel
    }

    // MARK: - Methods
    
    func saveAndUpdateTimes(focusedIime: Int, restTime: Int) {
        settingsModel.saveTime(time: focusedIime, for: UserDefaultKeys.focusedTime)
        settingsModel.saveTime(time: restTime, for: UserDefaultKeys.restTime)

        self.focusedTime = String(describing: getTimeInMinutes(for: UserDefaultKeys.focusedTime))

        self.restTime = String(describing: getTimeInMinutes(for: UserDefaultKeys.restTime))
    }

    func getTimeInMinutes(for key: String) -> Int {
        let timeInMinutes = settingsModel.getTime(for: key) / 60
        return timeInMinutes == 0 ? 1 : timeInMinutes
    }
}
