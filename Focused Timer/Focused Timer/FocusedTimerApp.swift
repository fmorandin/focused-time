//
//  Focused_TimerApp.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 28/09/20.
//

import SwiftUI
import os

@main
struct FocusedTimerApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppDelegate.self)
    )

    // MARK: - Computed Variables

    static var isUITestingEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("UI-Testing")
    }

    // MARK: - Public Methods

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        setStateForUITesting()

        requestLocalNotificationPermission()

        UNUserNotificationCenter.current().delegate = self
        UserDefaults.standard.set(false, forKey: UserDefaultKeys.isNotification)

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isNotification)
        completionHandler()
    }

    func requestLocalNotificationPermission() {

        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [
                .alert,
                .sound,
                .badge
            ]) { _, error in

                Self.logger.notice("📅 Requesting user's permission to send notifications.")

                if let error = error {
                    Self.logger.error(
                        "👮🏻‍♂️ Problem requesting user's permission for notification: \(error.localizedDescription)"
                    )
                }
            }
    }

    // MARK: - Private Methods

    private func setStateForUITesting() {

        if AppDelegate.isUITestingEnabled {

            Self.logger.notice("📲 Starting UI Testing.")

            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.set("4", forKey: UserDefaultKeys.numberOfCycles)
            UserDefaults.standard.set(60, forKey: UserDefaultKeys.focusedTime)
            UserDefaults.standard.set(60, forKey: UserDefaultKeys.shortBreakTime)
            UserDefaults.standard.set(60, forKey: UserDefaultKeys.longBreakTime)

            UserDefaults.standard.set(false, forKey: UserDefaultKeys.autoStartToggle)
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.playTimerSounds)

            UIView.setAnimationsEnabled(false)
        }
    }
}
