//
//  LocalNotificationManagerTests.swift
//  Focused TimerTests
//

import XCTest
import UserNotifications
@testable import Focused_Timer

final class LocalNotificationManagerTests: XCTestCase {

    private final class NotificationCenterMock: UserNotificationCenterProtocol {
        var authorizationStatus: UNAuthorizationStatus = .notDetermined
        private(set) var badgeValues: [Int] = []
        private(set) var removedPendingCalls = 0
        private(set) var removedDeliveredCalls = 0
        private(set) var addedRequests: [UNNotificationRequest] = []

        func setBadge(to value: Int) {
            badgeValues.append(value)
        }

        func removeAllPendingNotificationRequests() {
            removedPendingCalls += 1
        }

        func removeAllDeliveredNotifications() {
            removedDeliveredCalls += 1
        }

        func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
            completionHandler(authorizationStatus)
        }

        func add(_ request: UNNotificationRequest) {
            addedRequests.append(request)
        }
    }

    func test_ClearScheduledNotifications_ClearsBadgeAndQueues() {
        let center = NotificationCenterMock()
        let manager = LocalNotificationManager(notificationCenter: center)

        manager.clearScheduledNotifications()

        XCTAssertEqual(center.badgeValues, [0])
        XCTAssertEqual(center.removedPendingCalls, 1)
        XCTAssertEqual(center.removedDeliveredCalls, 1)
    }

    func test_ScheduleLocalNotification_WhenStatusNotDetermined_RequestsPermissionOnly() {
        let center = NotificationCenterMock()
        center.authorizationStatus = .notDetermined
        var requestPermissionCalls = 0
        let manager = LocalNotificationManager(
            notificationCenter: center,
            requestPermission: { requestPermissionCalls += 1 }
        )

        manager.scheduleLocalNotification(remainingTime: 12)

        XCTAssertEqual(requestPermissionCalls, 1)
        XCTAssertTrue(center.addedRequests.isEmpty)
    }

    func test_ScheduleLocalNotification_WhenAuthorized_AddsRequestWithExpectedTriggerTime() {
        let center = NotificationCenterMock()
        center.authorizationStatus = .authorized
        let manager = LocalNotificationManager(notificationCenter: center)

        manager.scheduleLocalNotification(remainingTime: 9)

        XCTAssertEqual(center.addedRequests.count, 1)
        let trigger = center.addedRequests.first?.trigger as? UNTimeIntervalNotificationTrigger
        XCTAssertEqual(trigger?.timeInterval, 9)
        XCTAssertEqual(trigger?.repeats, false)
    }

    func test_ScheduleLocalNotification_WhenDenied_DoesNotRequestPermissionOrSchedule() {
        let center = NotificationCenterMock()
        center.authorizationStatus = .denied
        var requestPermissionCalls = 0
        let manager = LocalNotificationManager(
            notificationCenter: center,
            requestPermission: { requestPermissionCalls += 1 }
        )

        manager.scheduleLocalNotification(remainingTime: 15)

        XCTAssertEqual(requestPermissionCalls, 0)
        XCTAssertTrue(center.addedRequests.isEmpty)
    }
}
