//
//  SettingsViewModelAppearanceModeTests.swift
//  Focused TimerTests
//

import Foundation
import Testing
@testable import Focused_Timer

@MainActor
@Suite("SettingsViewModel AppearanceMode Tests", .serialized)
struct SettingsViewModelAppearanceModeTests {

    private final class SettingsModelSpy: SettingsModelProtocol {
        var savedAppearanceMode: AppearanceMode?
        var stubbedAppearanceMode: AppearanceMode = .system

        func saveTime(time: Int, for keyName: String) {}
        func getTime(for _: String) -> Int { 1500 }
        func saveNumberOfCycles(numberOfCycles: Int, for keyName: String) {}
        func getNumberOfCycles(for _: String) -> String { "4" }
        func saveToggle(value: Bool, for keyName: String) {}
        func getToggle(for _: String) -> Bool { false }
        func getStartingTimerType() -> TimerType { .focused }
        func saveStartingTimerType(_ type: TimerType) {}

        func getAppearanceMode() -> AppearanceMode { stubbedAppearanceMode }

        func saveAppearanceMode(_ mode: AppearanceMode) {
            savedAppearanceMode = mode
        }

        func getLiveActivitiesEnabled() -> Bool { true }
        func saveLiveActivitiesEnabled(_ isEnabled: Bool) {}
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
            UserDefaultKeys.keepScreenOn,
            UserDefaultKeys.enableNotifications,
            UserDefaultKeys.startingTimerType,
            UserDefaultKeys.appearanceMode,
            UserDefaultKeys.liveActivitiesEnabled
        ].forEach { defaults.removeObject(forKey: $0) }
    }

    private func makePersistedSUT() -> SettingsViewModel {
        clearPersistedValues()
        return SettingsViewModel(settingsModel: SettingsModel())
    }

    // MARK: - Tests

    @Test("appearanceMode is populated from the model on init")
    func appearanceModePopulatedOnInit() {
        let settingsModel = SettingsModelSpy()
        settingsModel.stubbedAppearanceMode = .dark
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)

        #expect(settingsViewModel.appearanceMode == .dark)
    }

    @Test("saveAppearanceMode persists the value and updates observable property")
    func saveAppearanceModePersistsValue() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)

        settingsViewModel.saveAppearanceMode(.light)

        #expect(settingsModel.savedAppearanceMode == .light)
        #expect(settingsViewModel.appearanceMode == .light)
    }

    @Test("resetToDefault resets appearanceMode to system")
    func resetToDefaultResetsAppearanceMode() {
        let settingsViewModel = makePersistedSUT()

        settingsViewModel.saveAppearanceMode(.dark)
        #expect(settingsViewModel.appearanceMode == .dark)

        settingsViewModel.resetToDefault()

        #expect(settingsViewModel.appearanceMode == .system)
    }
}
