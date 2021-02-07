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
    }

    override class func tearDown() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.focusedTime)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.restTime)
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

}
