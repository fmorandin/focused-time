//
//  Focused_TimerApp.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 28/09/20.
//

import SwiftUI

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

    static var isUITestingEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("UI-Testing")
    }

    func requestLocalNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
    }

    private func setStateForUITesting() {
        if AppDelegate.isUITestingEnabled {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.set("4", forKey: UserDefaultKeys.cycleTotal)
            UserDefaults.standard.set(60, forKey: UserDefaultKeys.focusedTime)
            UserDefaults.standard.set(60, forKey: UserDefaultKeys.restTime)
            UserDefaults.standard.set(60, forKey: UserDefaultKeys.longBreak)
        }
    }
}
