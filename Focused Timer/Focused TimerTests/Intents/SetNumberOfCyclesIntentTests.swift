//
//  SetNumberOfCyclesIntentTests.swift
//  Focused TimerTests
//
//  Tests that SettingsModel correctly saves cycle count —
//  the same path SetNumberOfCyclesIntent.perform() exercises.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("SetNumberOfCyclesIntent")
struct SetNumberOfCyclesIntentTests {

    @Test("saves correct cycle count via UserDefaults")
    func savesCorrectCycleCount() {
        let settingsModel = SettingsModel()

        settingsModel.saveNumberOfCycles(numberOfCycles: 6, for: UserDefaultKeys.numberOfCycles)

        // saveNumberOfCycles stores an Int; getNumberOfCycles reads it as a String
        // via UserDefaults which handles the type bridging
        let savedValue = settingsModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles)
        #expect(savedValue == "6")
    }

}
