//
//  BaseFeature.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest

class BaseFeature: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: "totalTime")
        super.setUp()
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        UserDefaults.standard.removeObject(forKey: "totalTime")
    }
}
