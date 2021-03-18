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
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.restTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.cycleTotal)
    }

    override class func tearDown() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.focusedTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.restTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.cycleTotal)
    }

    func test_GetFocusedTime() throws {

        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the total time should be returned
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: "focusedTime"), 25)
    }

    func test_GetRestTimer() throws {

        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the total time should be returned
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: "restTime"), 5)
    }

    func test_SaveTimers() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any total time yet
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 1)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.restTime), 1)

        // WHEN I call the function to save the new value
        settingsViewModel.saveAndUpdateTimes(focusedIime: 20, restTime: 5)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.focusedTime), 20)
        XCTAssertEqual(settingsViewModel.getTimeInMinutes(for: UserDefaultKeys.restTime), 5)
    }

    func test_SaveNumberOfCycles() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set the number of cycles yet
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.cycleTotal), 0)

        // WHEN I call the function to save the new value
        settingsViewModel.saveNumberOfCycles(5)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.cycleTotal), 5)
    }

    func test_GetNumberOfCycles() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the number of cycles will be returned correctly
        XCTAssertEqual(settingsViewModel.getNumberOfCycles(for: UserDefaultKeys.cycleTotal), 10)
    }

}
