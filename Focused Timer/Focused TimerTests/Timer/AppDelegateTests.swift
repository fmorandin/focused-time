//
//  AppDelegateTests.swift
//  Focused TimerTests
//

import XCTest
import UIKit
@testable import Focused_Timer

@MainActor
final class AppDelegateTests: XCTestCase {

    private final class AppDelegateSpy: AppDelegate {
        private(set) var requestPermissionCalls = 0

        override func requestLocalNotificationPermission() {
            requestPermissionCalls += 1
        }
    }

    func test_DidFinishLaunching_ResetsNotificationFlagAndRequestsPermission() {
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isNotification)
        let appDelegate = AppDelegateSpy()

        let result = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        XCTAssertTrue(result)
        XCTAssertEqual(appDelegate.requestPermissionCalls, 1)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotification))
    }
}
