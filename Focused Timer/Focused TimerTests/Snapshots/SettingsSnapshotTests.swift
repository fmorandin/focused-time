//
//  SettingsSnapshotTests.swift
//  Focused TimerTests
//

import SnapshotTesting
import SwiftUI
import UIKit
import UserNotifications
import XCTest

@testable import Focused_Timer

@MainActor
final class SettingsSnapshotTests: XCTestCase, @unchecked Sendable {

    // MARK: - Stubs

    private final class NotificationCenterDeniedStub: @unchecked Sendable, UserNotificationCenterProtocol {
        func setBadge(to _: Int) {}
        func removeAllPendingNotificationRequests() {}
        func removeAllDeliveredNotifications() {}
        func getAuthorizationStatus(completionHandler: @escaping @Sendable (UNAuthorizationStatus) -> Void) {
            completionHandler(.denied)
        }
        func add(_: UNNotificationRequest) {}
    }

    private final class NotificationCenterAuthorizedStub: @unchecked Sendable, UserNotificationCenterProtocol {
        func setBadge(to _: Int) {}
        func removeAllPendingNotificationRequests() {}
        func removeAllDeliveredNotifications() {}
        func getAuthorizationStatus(completionHandler: @escaping @Sendable (UNAuthorizationStatus) -> Void) {
            completionHandler(.authorized)
        }
        func add(_: UNNotificationRequest) {}
    }

    // MARK: - AppSettingsView: Notification States

    func test_appSettingsView_notificationsEnabled() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        viewModel.isNotificationsDeniedBySystem = false
        viewModel.isNotificationsEnabled = true
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_appSettingsView_notificationsDeniedBySystem() {
        let viewModel = SettingsViewModel(
            settingsModel: SettingsModelMock(),
            notificationCenter: NotificationCenterDeniedStub()
        )
        viewModel.isNotificationsDeniedBySystem = true
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    // MARK: - AppSettingsView: Toggle States

    func test_appSettingsView_allTogglesEnabled() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        viewModel.isAutoStartEnabled = true
        viewModel.isPlaySoundEnabled = true
        viewModel.keepScreenOn = true
        viewModel.isAlarmEnabled = true
        viewModel.isNotificationsEnabled = true
        viewModel.isNotificationsDeniedBySystem = false
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_appSettingsView_allTogglesDisabled() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        viewModel.isAutoStartEnabled = false
        viewModel.isPlaySoundEnabled = false
        viewModel.keepScreenOn = false
        viewModel.isNotificationsEnabled = false
        viewModel.isNotificationsDeniedBySystem = false
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_appSettingsView_alarmAutoStartConflict() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        viewModel.isAutoStartEnabled = true
        viewModel.isAlarmDeniedBySystem = false
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    // MARK: - AppSettingsView: Starting Timer Type

    func test_appSettingsView_startingTimerType_focused() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        viewModel.startingTimerType = .focused
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_appSettingsView_startingTimerType_shortBreak() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        viewModel.startingTimerType = .shortBreak
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_appSettingsView_startingTimerType_longBreak() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        viewModel.startingTimerType = .longBreak
        let view = Form { AppSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    // MARK: - TimerSettingsView

    func test_timerSettingsView_defaultValues() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        let view = Form { TimerSettingsView(viewModel: viewModel) }
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    // MARK: - FormView: Warning Banner Variations

    func test_formView_withoutWarning() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        let view = NavigationStack { FormView(viewModel: viewModel, displayWarning: false) }
            .environment(Router())
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_formView_withWarning() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        let view = NavigationStack { FormView(viewModel: viewModel, displayWarning: true) }
            .environment(Router())
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }
}
