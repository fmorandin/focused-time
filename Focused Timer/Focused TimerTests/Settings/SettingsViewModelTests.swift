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
    }

    override class func tearDown() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.focusedTime)
    }

    func test_GetFocusedTime() throws {

        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the total time should be returned
        XCTAssertEqual(settingsViewModel.getFocusedTime(for: ""), 5)
    }

    func test_SaveFocusedTime() throws {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any total time yet
        XCTAssertEqual(settingsViewModel.getFocusedTime(for: UserDefaultKeys.focusedTime), 1)

        // WHEN I call the function to save the new value
        settingsViewModel.saveAndUpdateFocusedTime(time: 20)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getFocusedTime(for: UserDefaultKeys.focusedTime), 1200)
    }

}
