//
//  Focused_TimerApp.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 28/09/20.
//

import AlarmKit
import SwiftUI
import os

@main
struct FocusedTimerApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// Shared navigation state injected into the entire view hierarchy.
    @State private var router = Router()

    @AppStorage(UserDefaultKeys.appearanceMode) private var appearanceMode: String = AppearanceMode.system.rawValue

    init() {
        // Eagerly initialize the shared TimerService so the singleton is ready
        // before any App Intent or view accesses it.
        _ = TimerService.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceMode)?.colorScheme)
        }
    }
}

// MARK: - AppDelegate

@MainActor
class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppDelegate.self)
    )

    private enum UITestEnvironmentKeys {

        static let numberOfCycles = "UI_TEST_NUMBER_OF_CYCLES"
        static let focusedTimeSeconds = "UI_TEST_FOCUSED_SECONDS"
        static let shortBreakTimeSeconds = "UI_TEST_SHORT_BREAK_SECONDS"
        static let longBreakTimeSeconds = "UI_TEST_LONG_BREAK_SECONDS"
    }

    // MARK: - Computed Variables

    static var isUITestingEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("UI-Testing")
    }

    // MARK: - Public Methods

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        UserDefaults.standard.register(defaults: [
            UserDefaultKeys.enableNotifications: true,
            UserDefaultKeys.enableAlarm: false
        ])

        setStateForUITesting()

        if !AppDelegate.isUITestingEnabled {
            requestLocalNotificationPermission()
            requestAlarmKitPermission()
        }

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
                Task { @MainActor in
                    Self.logger.notice("📅 Requesting user's permission to send notifications.")
                    if let error = error {
                        Self.logger.error(
                            "👮🏻‍♂️ Problem requesting user's permission for notification: \(error.localizedDescription)"
                        )
                    }
                }
            }
    }

    func requestAlarmKitPermission() {

        Task {
            do {
                let state = try await AlarmManager.shared.requestAuthorization()
                Self.logger.notice("🔔 AlarmKit authorization state: \(String(describing: state)).")
            } catch {
                Self.logger.error("🚨 AlarmKit authorization request failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private Methods

    private func setStateForUITesting() {

        if AppDelegate.isUITestingEnabled {

            Self.logger.notice("📲 Starting UI Testing.")

            let environment = ProcessInfo.processInfo.environment
            let numberOfCycles = Int(environment[UITestEnvironmentKeys.numberOfCycles] ?? "") ?? 4
            let focusedTime = Int(environment[UITestEnvironmentKeys.focusedTimeSeconds] ?? "") ?? 60
            let shortBreakTime = Int(environment[UITestEnvironmentKeys.shortBreakTimeSeconds] ?? "") ?? 60
            let longBreakTime = Int(environment[UITestEnvironmentKeys.longBreakTimeSeconds] ?? "") ?? 60

            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.set("\(numberOfCycles)", forKey: UserDefaultKeys.numberOfCycles)
            UserDefaults.standard.set(focusedTime, forKey: UserDefaultKeys.focusedTime)
            UserDefaults.standard.set(shortBreakTime, forKey: UserDefaultKeys.shortBreakTime)
            UserDefaults.standard.set(longBreakTime, forKey: UserDefaultKeys.longBreakTime)

            UserDefaults.standard.set(false, forKey: UserDefaultKeys.autoStartToggle)
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.playTimerSounds)
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.enableNotifications)
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.enableAlarm)

            UIView.setAnimationsEnabled(false)
        }
    }
}
