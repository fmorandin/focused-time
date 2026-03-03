//
//  SettingsViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import Foundation
import Testing
@testable import Focused_Timer

@MainActor
@Suite("SettingsViewModel Tests", .serialized)
struct SettingsViewModelTests {

    private final class SettingsModelSpy: SettingsModelProtocol {
        var savedTimes: [(Int, String)] = []
        var savedCycles: [(Int, String)] = []
        var savedToggles: [(Bool, String)] = []

        func saveTime(time: Int, for keyName: String) {
            savedTimes.append((time, keyName))
        }

        func getTime(for _: String) -> Int {
            1500
        }

        func saveNumberOfCycles(numberOfCycles: Int, for keyName: String) {
            savedCycles.append((numberOfCycles, keyName))
        }

        func getNumberOfCycles(for _: String) -> String {
            "4"
        }

        func saveToggle(value: Bool, for keyName: String) {
            savedToggles.append((value, keyName))
        }

        func getToggle(for _: String) -> Bool {
            false
        }
    }

    private func clearPersistedValues() {
        let defaults = UserDefaults.standard
        [
            UserDefaultKeys.focusedTime,
            UserDefaultKeys.shortBreakTime,
            UserDefaultKeys.numberOfCycles,
            UserDefaultKeys.longBreakTime,
            UserDefaultKeys.autoStartToggle,
            UserDefaultKeys.playTimerSounds,
            UserDefaultKeys.keepScreenOn
        ].forEach { defaults.removeObject(forKey: $0) }
    }

    private func makePersistedSUT() -> SettingsViewModel {
        clearPersistedValues()
        return SettingsViewModel(settingsModel: SettingsModel())
    }

    @Test(
        "getTimeInMinutes returns expected values from mock settings",
        arguments: [
            ("focusedTime", 25),
            ("shortBreakTime", 5),
            ("longBreak", 30)
        ]
    )
    func getTimeInMinutesFromMock(keyName: String, expected: Int) {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        #expect(settingsViewModel.getTimeInMinutes(for: keyName) == expected)
    }

    @Test("saveTime persists valid values")
    func saveTimers() {
        let settingsViewModel = makePersistedSUT()

        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime) == 25)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime) == 5)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime) == 30)

        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: 20)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: 5)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: 30)

        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime) == 20)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime) == 5)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime) == 30)
    }

    @Test("saveNumberOfCycles persists valid value")
    func saveNumberOfCycles() {
        let settingsViewModel = makePersistedSUT()

        #expect(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == 4)

        settingsViewModel.saveNumberOfCycles(5)

        #expect(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == 5)
    }

    @Test("getNumberOfCycles returns value from mock")
    func getNumberOfCycles() {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        #expect(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == 10)
    }

    @Test(
        "getSavedToggles returns expected values from mock settings",
        arguments: [
            UserDefaultKeys.autoStartToggle,
            UserDefaultKeys.playTimerSounds,
            UserDefaultKeys.keepScreenOn
        ]
    )
    func getToggles(keyName: String) {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        #expect(settingsViewModel.getSavedToggles(for: keyName) == false)
    }

    @Test("saveToggles persists updated values")
    func saveToggles() {
        let settingsViewModel = makePersistedSUT()

        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle) == false)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds) == false)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn) == false)

        settingsViewModel.saveToggles(for: UserDefaultKeys.autoStartToggle, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.playTimerSounds, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.keepScreenOn, value: true)

        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle) == true)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds) == true)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn) == true)
    }

    @Test("negative time values are ignored")
    func negativeTimeValues() {
        let settingsViewModel = makePersistedSUT()

        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime) == 25)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime) == 5)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime) == 30)

        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: -20)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: -10)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: -30)

        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime) == 25)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime) == 5)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime) == 30)
    }

    @Test("negative number of cycles is ignored")
    func negativeNumberOfCyclesValue() {
        let settingsViewModel = makePersistedSUT()

        #expect(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == 4)

        settingsViewModel.saveNumberOfCycles(-5)

        #expect(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == 4)
    }

    @Test("zero time values are not persisted")
    func zeroTimeValuesAreNotPersisted() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)

        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: 0)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: 0)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: 0)

        #expect(settingsModel.savedTimes.isEmpty)
    }

    @Test("zero number of cycles is not persisted")
    func zeroNumberOfCyclesAreNotPersisted() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)

        settingsViewModel.saveNumberOfCycles(0)

        #expect(settingsModel.savedCycles.isEmpty)
    }

    // MARK: - Metadata and Field Limits

    @Test("appVersionNumber returns a non-empty, non-fallback version string")
    func appVersionNumberIsNonEmpty() {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        #expect(!settingsViewModel.appVersionNumber.isEmpty)
        // "0" is the fallback returned when CFBundleShortVersionString is missing from Info.plist
        #expect(settingsViewModel.appVersionNumber != "0")
    }

    @Test("timerLimits maximum character count is 3")
    func timerLimitsConstantIsThree() {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        #expect(settingsViewModel.timerLimits == 3)
    }

    @Test("numberOfCyclesLimits maximum character count is 2")
    func numberOfCyclesLimitsConstantIsTwo() {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        #expect(settingsViewModel.numberOfCyclesLimits == 2)
    }

    @Test("resetToDefault restores all default settings")
    func resetDefaultValues() {
        let settingsViewModel = makePersistedSUT()

        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime) == 25)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime) == 5)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime) == 30)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle) == false)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds) == false)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn) == false)

        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: 20)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: 10)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: 40)
        settingsViewModel.saveToggles(for: UserDefaultKeys.autoStartToggle, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.playTimerSounds, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.keepScreenOn, value: true)

        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime) == 20)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime) == 10)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime) == 40)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle) == true)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds) == true)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn) == true)

        settingsViewModel.resetToDefault()

        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime) == 25)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime) == 5)
        #expect(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime) == 30)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle) == false)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds) == false)
        #expect(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn) == false)
    }
}
