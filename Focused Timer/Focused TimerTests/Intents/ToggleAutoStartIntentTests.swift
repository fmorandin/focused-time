//
//  ToggleAutoStartIntentTests.swift
//  Focused TimerTests
//
//  Tests that SettingsModel correctly saves auto-start toggle —
//  the same path ToggleAutoStartIntent.perform() exercises.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("ToggleAutoStartIntent")
struct ToggleAutoStartIntentTests {

    @Test("saves true correctly via SettingsModel")
    func savesEnabled() {
        let repository = InMemoryStorageRepository()
        let settingsModel = SettingsModel(repository: repository)

        settingsModel.saveToggle(value: true, for: UserDefaultKeys.autoStartToggle)

        #expect(settingsModel.getToggle(for: UserDefaultKeys.autoStartToggle) == true)
    }

    @Test("saves false correctly via SettingsModel")
    func savesDisabled() {
        let repository = InMemoryStorageRepository()
        let settingsModel = SettingsModel(repository: repository)

        settingsModel.saveToggle(value: true, for: UserDefaultKeys.autoStartToggle)
        settingsModel.saveToggle(value: false, for: UserDefaultKeys.autoStartToggle)

        #expect(settingsModel.getToggle(for: UserDefaultKeys.autoStartToggle) == false)
    }

}
