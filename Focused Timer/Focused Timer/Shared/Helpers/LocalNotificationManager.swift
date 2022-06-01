//
//  LocalNotificationManager.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 08/03/21.
//

import Foundation
import UIKit
import UserNotifications
import os

struct LocalNotificationManager {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: LocalNotificationManager.self)
    )

    // MARK: - Public Functions

    /// Function that will cancel all the scheduled notification and
    /// also clears the already sent notifications
    func clearScheduledNotifications() {

        Self.logger.notice("🧹 Cleanning up all the scheduled notifications.")

        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    /// Function that will receive the request to schedule a notification and
    /// checks if the permission is given
    /// - Parameter remainingTime: the time that is remaining for the timer to finishes
    func scheduleLocalNotification(remainingTime: Double) {

        Self.logger.notice("🕵🏻 Checking the status of the permission to send local notifications.")

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                Self.logger.notice("🧐 Permission for local notification not determined.")
                AppDelegate().requestLocalNotificationPermission()
            case .authorized, .provisional:
                Self.logger.notice("👌🏻 Permission for local notification either authorized or provisional.")
                self.schedule(remainingTime: remainingTime)
            default:
                Self.logger.error("✋🏻 Default option for local notification permissions.")
            }
        }
    }

    // MARK: - Private Functions

    /// Function that will schedule a notification based on the remaining time for the given timer to finish
    /// - Parameters:
    ///   - remainingTime: The remaining time for the timer to finish
    private func schedule(remainingTime: Double) {

        let center = UNUserNotificationCenter.current()

        let notificationTitle = NSString.localizedUserNotificationString(
            forKey: "notificationTitle", arguments: nil)
        let notificationBody = NSString.localizedUserNotificationString(
            forKey: "notificationBody", arguments: nil)

        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.categoryIdentifier = "TIMER_EXPIRED"
        content.sound = UNNotificationSound.default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingTime, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request)

        Self.logger.notice("📆 Local notification scheduled.")
    }
}
