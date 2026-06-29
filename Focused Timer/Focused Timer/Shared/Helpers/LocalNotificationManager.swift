//
//  LocalNotificationManager.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 08/03/21.
//

import Foundation
import UIKit
@preconcurrency import UserNotifications
import os

protocol UserNotificationCenterProtocol: Sendable {
    func setBadge(to value: Int)
    func removeAllPendingNotificationRequests()
    func removeAllDeliveredNotifications()
    func getAuthorizationStatus(completionHandler: @escaping @Sendable (UNAuthorizationStatus) -> Void)
    func add(_ request: UNNotificationRequest)
}

extension UserNotificationCenterProtocol {

    /// Async wrapper around the completion-handler based `getAuthorizationStatus`.
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            self.getAuthorizationStatus { status in
                continuation.resume(returning: status)
            }
        }
    }
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {

    func setBadge(to value: Int) {
        setBadgeCount(value)
    }

    func getAuthorizationStatus(completionHandler: @escaping @Sendable (UNAuthorizationStatus) -> Void) {
        getNotificationSettings { settings in
            completionHandler(settings.authorizationStatus)
        }
    }

    func add(_ request: UNNotificationRequest) {
        add(request, withCompletionHandler: nil)
    }
}

protocol LocalNotificationManaging {
    func clearScheduledNotifications()
    func scheduleLocalNotification(remainingTime: Double, timerType: TimerType)
}

struct LocalNotificationManager {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: LocalNotificationManager.self)
    )
    private let notificationCenter: any UserNotificationCenterProtocol
    private let requestPermission: @Sendable () -> Void

    init(
        notificationCenter: any UserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        requestPermission: @escaping @Sendable () -> Void = {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { _, error in
                if let error {
                    Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "FocusedTimer",
                        category: "LocalNotificationManager"
                    ).error(
                        "👮🏻‍♂️ Problem requesting user's permission for notification: \(error.localizedDescription)"
                    )
                }
            }
        }
    ) {
        self.notificationCenter = notificationCenter
        self.requestPermission = requestPermission
    }

    // MARK: - Public Functions

    /// Function that will cancel all the scheduled notification and
    /// also clears the already sent notifications
    func clearScheduledNotifications() {

        Self.logger.notice("🧹 Cleaning up all the scheduled notifications.")

        notificationCenter.setBadge(to: 0)
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    /// Function that will receive the request to schedule a notification and
    /// checks if the permission is given
    /// - Parameters:
    ///   - remainingTime: the time that is remaining for the timer to finish
    ///   - timerType: the type of timer that is currently running
    func scheduleLocalNotification(remainingTime: Double, timerType: TimerType) {

        Self.logger.notice("🕵🏻 Checking the status of the permission to send local notifications.")

        let requestPermission = self.requestPermission
        let notificationCenter = self.notificationCenter
        let timerTypeName = String(localized: timerType.getCorrectTranslation())
        notificationCenter.getAuthorizationStatus { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                Self.logger.notice("🧐 Permission for local notification not determined.")
                requestPermission()
            case .authorized, .provisional:
                Self.logger.notice("👌🏻 Permission for local notification either authorized or provisional.")
                Self.schedule(
                    remainingTime: remainingTime,
                    timerTypeName: timerTypeName,
                    notificationCenter: notificationCenter
                )
            default:
                Self.logger.error("✋🏻 Default option for local notification permissions.")
            }
        }
    }

    // MARK: - Private Functions

    /// Function that will schedule a notification based on the remaining time for the given timer to finish
    /// - Parameters:
    ///   - remainingTime: The remaining time for the timer to finish
    ///   - timerTypeName: The localized name of the timer type that is running
    private static func schedule(
        remainingTime: Double,
        timerTypeName: String,
        notificationCenter: any UserNotificationCenterProtocol
    ) {
        let notificationTitle = NSString.localizedUserNotificationString(
            forKey: "notificationTitleWithType", arguments: [timerTypeName])
        let notificationBody = NSString.localizedUserNotificationString(
            forKey: "notificationBodyWithType", arguments: [timerTypeName])

        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.categoryIdentifier = "TIMER_EXPIRED"
        content.sound = UNNotificationSound.default
        content.badge = 1

        // `UNTimeIntervalNotificationTrigger` requires a strictly positive interval, so clamp to a 1s minimum.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, remainingTime), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        notificationCenter.add(request)

        Self.logger.notice("📆 Local notification scheduled.")
    }
}

extension LocalNotificationManager: LocalNotificationManaging {}
