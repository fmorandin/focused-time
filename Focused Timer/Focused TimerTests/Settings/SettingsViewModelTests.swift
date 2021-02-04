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
        UserDefaults.standard.removeObject(forKey: "focusedTime")
    }

    override class func tearDown() {
        UserDefaults.standard.removeObject(forKey: "focusedTime")
    }

    func test_GetFocusedTime() {

        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModelMock())

        // THEN the total time should be returned
        XCTAssertEqual(settingsViewModel.getFocusedTime(), 5)
    }

    func test_SaveFocusedTime() {
        let settingsViewModel = SettingsViewModel(settingsModel: SettingsModel())

        // GIVEN I have not set any total time yet
        XCTAssertEqual(settingsViewModel.getFocusedTime(), 1)

        // WHEN I call the function to save the new value
        settingsViewModel.saveAndUpdateFocusedTime(time: 20)

        // THEN the total time should be updated
        XCTAssertEqual(settingsViewModel.getFocusedTime(), 1200)
    }

}
