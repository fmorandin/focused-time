//
//  LocalNotificationManagerTests.swift
//  Focused TimerTests
//

import Testing
import UserNotifications
@testable import Focused_Timer

@Suite("LocalNotificationManager Tests", .serialized)
struct LocalNotificationManagerTests {

    private final class PermissionCallCounter: @unchecked Sendable {
        var value = 0
    }

    private final class NotificationCenterMock: @unchecked Sendable, UserNotificationCenterProtocol {
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

        func getAuthorizationStatus(completionHandler: @escaping @Sendable (UNAuthorizationStatus) -> Void) {
            completionHandler(authorizationStatus)
        }

        func add(_ request: UNNotificationRequest) {
            addedRequests.append(request)
        }
    }

    @Test("clearScheduledNotifications clears badge and pending/delivered queues")
    func clearScheduledNotificationsClearsBadgeAndQueues() {
        let center = NotificationCenterMock()
        let manager = LocalNotificationManager(notificationCenter: center)

        manager.clearScheduledNotifications()

        #expect(center.badgeValues == [0])
        #expect(center.removedPendingCalls == 1)
        #expect(center.removedDeliveredCalls == 1)
    }

    @Test("scheduleLocalNotification requests permission when authorization is not determined")
    func scheduleLocalNotificationWhenStatusNotDeterminedRequestsPermissionOnly() {
        let center = NotificationCenterMock()
        center.authorizationStatus = .notDetermined
        let requestPermissionCalls = PermissionCallCounter()
        let manager = LocalNotificationManager(
            notificationCenter: center,
            requestPermission: { requestPermissionCalls.value += 1 }
        )

        manager.scheduleLocalNotification(remainingTime: 12, timerType: .focused)

        #expect(requestPermissionCalls.value == 1)
        #expect(center.addedRequests.isEmpty)
    }

    @Test("scheduleLocalNotification adds non-repeating request when authorized")
    func scheduleLocalNotificationWhenAuthorizedAddsRequestWithExpectedTriggerTime() throws {
        let center = NotificationCenterMock()
        center.authorizationStatus = .authorized
        let manager = LocalNotificationManager(notificationCenter: center)

        manager.scheduleLocalNotification(remainingTime: 9, timerType: .focused)

        #expect(center.addedRequests.count == 1)
        let request = try #require(center.addedRequests.first)
        let trigger = try #require(request.trigger as? UNTimeIntervalNotificationTrigger)
        #expect(trigger.timeInterval == 9)
        #expect(!trigger.repeats)
    }

    @Test("scheduleLocalNotification ignores denied authorization")
    func scheduleLocalNotificationWhenDeniedDoesNotRequestPermissionOrSchedule() {
        let center = NotificationCenterMock()
        center.authorizationStatus = .denied
        let requestPermissionCalls = PermissionCallCounter()
        let manager = LocalNotificationManager(
            notificationCenter: center,
            requestPermission: { requestPermissionCalls.value += 1 }
        )

        manager.scheduleLocalNotification(remainingTime: 15, timerType: .focused)

        #expect(requestPermissionCalls.value == 0)
        #expect(center.addedRequests.isEmpty)
    }
}
