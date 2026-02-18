//
//  AppDelegateTests.swift
//  Focused TimerTests
//

import Testing
import UIKit
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
}
