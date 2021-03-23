//
//  SettingsViewModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 10/01/21.
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
    @Published var cycleTotal: String
    @Published var longBreak: String

    // MARK: - Initializer

    init(settingsModel: SettingsModelProtocol) {
        self.settingsModel = settingsModel

        let focusedTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.focusedTime)
        let focusedTimeInMinutes = focusedTimeInSeconds / 60
        self.focusedTime = String(describing: focusedTimeInMinutes == 0 ? 1 : focusedTimeInMinutes)

        let restTimeInSeconds = settingsModel.getTime(for: UserDefaultKeys.restTime)
        let restTimeInMinutes = restTimeInSeconds / 60
        self.restTime = String(describing: restTimeInMinutes == 0 ? 1 : restTimeInMinutes)

        self.cycleTotal = settingsModel.getCycleTotal(for: UserDefaultKeys.cycleTotal)

        let longBreakInSeconds = settingsModel.getTime(for: UserDefaultKeys.longBreak)
        let longBrakInMinutes = longBreakInSeconds / 60
        self.longBreak = String(describing: longBrakInMinutes == 0 ? 1 : longBrakInMinutes)
    }

    // MARK: - Methods

    func saveAndUpdateTimes(focusedIime: Int, restTime: Int, longBreak: Int) {
        settingsModel.saveTime(time: focusedIime, for: UserDefaultKeys.focusedTime)
        settingsModel.saveTime(time: restTime, for: UserDefaultKeys.restTime)
        settingsModel.saveTime(time: longBreak, for: UserDefaultKeys.longBreak)

        self.focusedTime = String(describing: getTimeInMinutes(for: UserDefaultKeys.focusedTime))
        self.restTime = String(describing: getTimeInMinutes(for: UserDefaultKeys.restTime))
        self.longBreak = String(describing: getTimeInMinutes(for: UserDefaultKeys.longBreak))
    }

    func getTimeInMinutes(for keyName: String) -> Int {
        let timeInMinutes = settingsModel.getTime(for: keyName) / 60
        return timeInMinutes == 0 ? 1 : timeInMinutes
    }

    func saveNumberOfCycles(_ numberOfCycles: Int) {
        settingsModel.saveCycleTotal(cycleNumber: numberOfCycles, for: UserDefaultKeys.cycleTotal)

        self.cycleTotal = String(describing: settingsModel.getCycleTotal(for: UserDefaultKeys.cycleTotal))
    }

    func getNumberOfCycles(for keyName: String) -> Int {
        Int(settingsModel.getCycleTotal(for: UserDefaultKeys.cycleTotal)) ?? 0
    }
}
