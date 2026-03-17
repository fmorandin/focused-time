//
//  SettingsViewModelToggleInteractionTests.swift
//  Focused TimerTests
//

import Foundation
import Testing
@testable import Focused_Timer

@MainActor
@Suite("SettingsViewModel Toggle Interaction Tests", .serialized)
struct SettingsViewModelToggleInteractionTests {

    private final class SettingsModelSpy: SettingsModelProtocol {
        var savedToggles: [(Bool, String)] = []

        func saveTime(time _: Int, for _: String) {}
        func getTime(for _: String) -> Int { 1500 }
        func saveNumberOfCycles(numberOfCycles _: Int, for _: String) {}
        func getNumberOfCycles(for _: String) -> String { "4" }
        func saveToggle(value: Bool, for keyName: String) { savedToggles.append((value, keyName)) }
        func getToggle(for _: String) -> Bool { false }
        func getStartingTimerType() -> TimerType { .focused }
        func saveStartingTimerType(_: TimerType) {}
        func getAppearanceMode() -> AppearanceMode { .system }
        func saveAppearanceMode(_: AppearanceMode) {}
    }

    // MARK: - Alarm / Notifications mutual exclusivity

    @Test("saveAlarmEnabled(true) disables notifications")
    func saveAlarmEnabledTrueDisablesNotifications() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.isNotificationsEnabled = true

        settingsViewModel.saveAlarmEnabled(true)

        #expect(settingsViewModel.isAlarmEnabled == true)
        #expect(settingsViewModel.isNotificationsEnabled == false)
        let savedNotification = settingsModel.savedToggles.last { $0.1 == UserDefaultKeys.enableNotifications }
        #expect(savedNotification?.0 == false)
    }

    @Test("saveAlarmEnabled(false) leaves notifications unchanged")
    func saveAlarmEnabledFalseDoesNotTouchNotifications() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.isNotificationsEnabled = true

        settingsViewModel.saveAlarmEnabled(false)

        #expect(settingsViewModel.isAlarmEnabled == false)
        #expect(settingsViewModel.isNotificationsEnabled == true)
        let savedNotification = settingsModel.savedToggles.first { $0.1 == UserDefaultKeys.enableNotifications }
        #expect(savedNotification == nil)
    }

    @Test("saveNotificationsEnabled(true) disables alarm")
    func saveNotificationsEnabledTrueDisablesAlarm() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.isAlarmEnabled = true

        settingsViewModel.saveNotificationsEnabled(true)

        #expect(settingsViewModel.isNotificationsEnabled == true)
        #expect(settingsViewModel.isAlarmEnabled == false)
        let savedAlarm = settingsModel.savedToggles.last { $0.1 == UserDefaultKeys.enableAlarm }
        #expect(savedAlarm?.0 == false)
    }

    @Test("saveNotificationsEnabled(false) leaves alarm unchanged")
    func saveNotificationsEnabledFalseDoesNotTouchAlarm() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.isAlarmEnabled = true

        settingsViewModel.saveNotificationsEnabled(false)

        #expect(settingsViewModel.isNotificationsEnabled == false)
        #expect(settingsViewModel.isAlarmEnabled == true)
        let savedAlarm = settingsModel.savedToggles.first { $0.1 == UserDefaultKeys.enableAlarm }
        #expect(savedAlarm == nil)
    }

    // MARK: - Auto-start interaction

    @Test("saveAutoStartEnabled(true) disables alarm and restores notifications")
    func saveAutoStartEnabledTrueDisablesAlarmAndRestoresNotifications() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.isAlarmEnabled = true
        settingsViewModel.isNotificationsEnabled = false

        settingsViewModel.saveAutoStartEnabled(true)

        #expect(settingsViewModel.isAutoStartEnabled == true)
        #expect(settingsViewModel.isAlarmEnabled == false)
        #expect(settingsViewModel.isNotificationsEnabled == true)
        let savedAlarm = settingsModel.savedToggles.last { $0.1 == UserDefaultKeys.enableAlarm }
        #expect(savedAlarm?.0 == false)
        let savedNotification = settingsModel.savedToggles.last { $0.1 == UserDefaultKeys.enableNotifications }
        #expect(savedNotification?.0 == true)
    }

    @Test("saveAutoStartEnabled(false) leaves alarm and notifications unchanged")
    func saveAutoStartEnabledFalseDoesNotTouchAlarmOrNotifications() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.isAlarmEnabled = true
        settingsViewModel.isNotificationsEnabled = false

        settingsViewModel.saveAutoStartEnabled(false)

        #expect(settingsViewModel.isAutoStartEnabled == false)
        #expect(settingsViewModel.isAlarmEnabled == true)
        #expect(settingsViewModel.isNotificationsEnabled == false)
        let savedAlarm = settingsModel.savedToggles.first { $0.1 == UserDefaultKeys.enableAlarm }
        #expect(savedAlarm == nil)
    }
}
