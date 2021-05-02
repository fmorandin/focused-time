//
//  SettingsViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest
@testable import Focused_Timer

class SettingsViewModelTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.focusedTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.shortBreakTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.numberOfCycles)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.longBreakTime)

        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.autoStartToggle)
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

    func test_GetToggle() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the number of cycles will be returned correctly
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), false)
    }

    func test_SaveToggles() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any toggle
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), false)

        // WHEN I call the function to save the new value
        settingsViewModel.saveToggles(autoStart: true)

        // THEN the toggle should be updated
        XCTAssertEqual(settingsViewModel.getSavedToggles(for: UserDefaultKeys.autoStartToggle), true)
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

    func test_ResetDefaultValues() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any total time yet
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 25)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)

        // WHEN I call the function to save the new value
        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: 20)
        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: 10)
        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: 40)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 20)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 10)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 40)

        // WHEN I reset to the default values
        settingsViewModel.resetToDefault()

        // THEN the values should be back to its default values
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 25)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.shortBreakTime), 5)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.longBreakTime), 30)
    }
}
