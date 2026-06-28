//
//  BaseFeature.swift
//  Focused TimerUITests
//
//  Created by Felipe Morandin on 31/01/21.
//

import XCTest

@MainActor
class BaseFeature: XCTestCase, @unchecked Sendable {

    let application = XCUIApplication()

    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            application.launchArguments += ["UI-Testing"]

            // Keep UI tests deterministic and fast by reducing cycle durations.
            application.launchEnvironment["UI_TEST_FOCUSED_SECONDS"] = "5"
            application.launchEnvironment["UI_TEST_SHORT_BREAK_SECONDS"] = "5"
            application.launchEnvironment["UI_TEST_LONG_BREAK_SECONDS"] = "5"
            application.launchEnvironment["UI_TEST_NUMBER_OF_CYCLES"] = "4"

            application.launch()
        }
    }

    override func tearDown() {
        MainActor.assumeIsolated {
            application.terminate()
        }
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

    @discardableResult
    func waitForValue(_ element: XCUIElement, equals value: String, timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    func slowTypeText(_ text: String, into element: XCUIElement, delay: useconds_t = 120_000) {
        element.tap()
        for character in text {
            element.typeText(String(character))
            usleep(delay)
        }
    }

    func tapToggle(_ element: XCUIElement) {
        let nestedSwitch = element.switches.firstMatch
        if nestedSwitch.exists {
            nestedSwitch.tap()
            return
        }

        element.tap()
    }
}
