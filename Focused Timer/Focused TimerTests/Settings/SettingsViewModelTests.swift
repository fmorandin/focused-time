//
//  SettingsViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest
@testable import Focused_Timer

final class SettingsViewModelTests: XCTestCase {

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

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.focusedTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.shortBreakTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.numberOfCycles)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.longBreakTime)

        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.autoStartToggle)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.playTimerSounds)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.keepScreenOn)
    }

    func test_GetFocusedTime() throws {

        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the total time should be returned
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: "focusedTime"), 25)
    }

    func test_GetShortBreakTimer() throws {

        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the total time should be returned
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: "shortBreakTime"), 5)
    }

    func test_GetLongBreak() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the total time should be returned
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: "longBreak"), 30)
    }

    func test_SaveTimers() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any total time yet
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 25)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)

        // WHEN I call the function to save the new value
        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: 20)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: 5)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: 30)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 20)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)
    }

    func test_SaveNumberOfCycles() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set the number of cycles yet
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles), 4)

        // WHEN I call the function to save the new value
        settingsViewModel.saveNumberOfCycles(5)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles), 5)
    }

    func test_GetNumberOfCycles() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the number of cycles will be returned correctly
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles), 10)
    }

    func test_GetToggles() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the value for the auto start will be returned correctly
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), false)

        // AND the value for the play sounds toggle should be returned correctly
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds), false)

        // AND the value for keep screen on toggle should be returned correctly
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn), false)
    }

    func test_SaveToggles() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any toggle
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), false)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds), false)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn), false)

        // WHEN I call the function to save the new values
        settingsViewModel.saveToggles(for: UserDefaultKeys.autoStartToggle, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.playTimerSounds, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.keepScreenOn, value: true)

        // THEN the toggles should be updated
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), true)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds), true)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn), true)
    }

    func test_NegativeTimeValues() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any total time yet
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 25)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)

        // WHEN I call the function to save the new value
        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: -20)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: -10)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: -30)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 25)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)
    }

    func test_NegativeNumberOfCyclesValue() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set the number of cycles yet
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles), 4)

        // WHEN I call the function to save the new value
        settingsViewModel.saveNumberOfCycles(-5)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles), 4)
    }

    func test_ZeroTimeValues_AreNotPersisted() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)

        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: 0)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: 0)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: 0)

        XCTAssertTrue(settingsModel.savedTimes.isEmpty)
    }

    func test_ZeroNumberOfCycles_AreNotPersisted() {
        let settingsModel = SettingsModelSpy()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)

        settingsViewModel.saveNumberOfCycles(0)

        XCTAssertTrue(settingsModel.savedCycles.isEmpty)
    }

    func test_ResetDefaultValues() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any total time yet
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 25)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), false)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds), false)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn), false)

        // WHEN I call the function to save the new value
        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: 20)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: 10)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: 40)
        settingsViewModel.saveToggles(for: UserDefaultKeys.autoStartToggle, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.playTimerSounds, value: true)
        settingsViewModel.saveToggles(for: UserDefaultKeys.keepScreenOn, value: true)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 20)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 10)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 40)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), true)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds), true)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn), true)

        // WHEN I reset to the default values
        settingsViewModel.resetToDefault()

        // THEN the values should be back to its default values
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 25)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), false)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.playTimerSounds), false)
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.keepScreenOn), false)
    }
}
