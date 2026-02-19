//
//  BaseFeature.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest

class BaseFeature: XCTestCase {

    let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        application.launchArguments += ["UI-Testing"]

        // Keep UI tests deterministic and fast by reducing cycle durations.
        application.launchEnvironment["UI_TEST_FOCUSED_SECONDS"] = "5"
        application.launchEnvironment["UI_TEST_SHORT_BREAK_SECONDS"] = "5"
        application.launchEnvironment["UI_TEST_LONG_BREAK_SECONDS"] = "5"
        application.launchEnvironment["UI_TEST_NUMBER_OF_CYCLES"] = "4"

        application.launch()
    }

    override func tearDown() {
        application.terminate()
    }

    @discardableResult
    func waitForLabel(_ element: XCUIElement, equals label: String, timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "label == %@", label)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @discardableResult
    func waitForLabel(_ element: XCUIElement, notEquals label: String, timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "label != %@", label)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @discardableResult
    func waitForExistence(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    func slowTypeText(_ text: String, into element: XCUIElement, delay: useconds_t = 120_000) {
        element.tap()
        for character in text {
            element.typeText(String(character))
            usleep(delay)
        }
    }
}
