//
//  SetTimerDurationIntentTests.swift
//  Focused TimerTests
//
//  Tests that SettingsModel correctly saves timer durations —
//  the same path SetTimerDurationIntent.perform() exercises.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("SetTimerDurationIntent")
struct SetTimerDurationIntentTests {

    @Test("saves correct value for focused timer type")
    func savesFocusedDuration() {
        let repository = InMemoryStorageRepository()
        let settingsModel = SettingsModel(repository: repository)

        settingsModel.saveTime(time: 30, for: TimerType.focused.userDefaultKey)

        let savedValue = settingsModel.getTime(for: UserDefaultKeys.focusedTime)
        #expect(savedValue == 1800)
    }

    @Test("saves correct value for short break timer type")
    func savesShortBreakDuration() {
        let repository = InMemoryStorageRepository()
        let settingsModel = SettingsModel(repository: repository)

        settingsModel.saveTime(time: 10, for: TimerType.shortBreak.userDefaultKey)

        let savedValue = settingsModel.getTime(for: UserDefaultKeys.shortBreakTime)
        #expect(savedValue == 600)
    }

    @Test("saves correct value for long break timer type")
    func savesLongBreakDuration() {
        let repository = InMemoryStorageRepository()
        let settingsModel = SettingsModel(repository: repository)

        settingsModel.saveTime(time: 15, for: TimerType.longBreak.userDefaultKey)

        let savedValue = settingsModel.getTime(for: UserDefaultKeys.longBreakTime)
        #expect(savedValue == 900)
    }

}
