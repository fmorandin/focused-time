//
//  AppDelegateTests.swift
//  Focused TimerTests
//

import Testing
import UIKit
import UserNotifications
@testable import Focused_Timer

@MainActor
@Suite("AppDelegate Tests", .serialized)
struct AppDelegateTests {

    private final class AppDelegateSpy: AppDelegate {
        private(set) var requestPermissionCalls = 0

        override func requestLocalNotificationPermission() {
            requestPermissionCalls += 1
        }
    }

    @Test("didFinishLaunching resets notification flag and requests notification permission")
    func didFinishLaunchingResetsNotificationFlagAndRequestsPermission() {
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isNotification)
        let appDelegate = AppDelegateSpy()

        let result = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        #expect(result)
        #expect(appDelegate.requestPermissionCalls == 1)
        #expect(!UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotification))
    }

    @Test("isUITestingEnabled returns false in the normal unit-test environment")
    func isUITestingEnabledReturnsFalseInNormalTests() {
        #expect(!AppDelegate.isUITestingEnabled)
    }

    @Test("didFinishLaunching registers the app delegate as UNUserNotificationCenter delegate")
    func didFinishLaunchingSetsNotificationCenterDelegate() {
        let appDelegate = AppDelegateSpy()
        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        // Verify the notification center delegate was set — it should be an AppDelegate instance.
        #expect(UNUserNotificationCenter.current().delegate is AppDelegate)
    }
}
