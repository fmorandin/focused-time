//
//  ToggleSoundIntentTests.swift
//  Focused TimerTests
//
//  Tests that SettingsModel correctly saves sound toggle —
//  the same path ToggleSoundIntent.perform() exercises.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("ToggleSoundIntent")
struct ToggleSoundIntentTests {

    @Test("saves true correctly via SettingsModel")
    func savesEnabled() {
        let repository = InMemoryStorageRepository()
        let settingsModel = SettingsModel(repository: repository)

        settingsModel.saveToggle(value: true, for: UserDefaultKeys.playTimerSounds)

        #expect(settingsModel.getToggle(for: UserDefaultKeys.playTimerSounds) == true)
    }

    @Test("saves false correctly via SettingsModel")
    func savesDisabled() {
        let repository = InMemoryStorageRepository()
        let settingsModel = SettingsModel(repository: repository)

        settingsModel.saveToggle(value: true, for: UserDefaultKeys.playTimerSounds)
        settingsModel.saveToggle(value: false, for: UserDefaultKeys.playTimerSounds)

        #expect(settingsModel.getToggle(for: UserDefaultKeys.playTimerSounds) == false)
    }

}
