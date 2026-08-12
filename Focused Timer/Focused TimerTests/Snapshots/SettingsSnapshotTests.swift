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

    private struct AlarmAuthorizationAuthorizedStub: AlarmAuthorizationChecking {
        let isDeniedBySystem = false
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
        let viewModel = SettingsViewModel(
            settingsModel: SettingsModelMock(),
            alarmAuthorizationChecker: AlarmAuthorizationAuthorizedStub()
        )
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
            .toolbar(.hidden, for: .navigationBar)
            .environment(Router())
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_formView_withWarning() {
        let viewModel = SettingsViewModel(settingsModel: SettingsModelMock())
        let view = NavigationStack { FormView(viewModel: viewModel, displayWarning: true) }
            .toolbar(.hidden, for: .navigationBar)
            .environment(Router())
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }
}

@MainActor
final class LiveActivitySnapshotTests: XCTestCase, @unchecked Sendable {

    private let referenceDate = Date(timeIntervalSince1970: 1_800_000_000)

    func test_lockScreen_runningFocus_light() {
        let view = lockScreen(state: state(phase: .focused, status: .running), style: .light)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 180)))
    }

    func test_lockScreen_pausedShortBreak_dark() {
        let view = lockScreen(state: state(phase: .shortBreak, status: .paused), style: .dark)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 180)))
    }

    func test_lockScreen_completedLongBreak_light() {
        let completedState = state(phase: .longBreak, status: .running).completed(at: referenceDate)
        let view = lockScreen(state: completedState, style: .light)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 180)))
    }

    func test_dynamicIsland_compact() {
        let currentState = state(phase: .focused, status: .running)
        let view = HStack {
            LiveActivityCompactLeadingView(phase: currentState.phase)
            Spacer()
            LiveActivityCompactTrailingView(state: currentState, referenceDate: referenceDate)
        }
        .padding(.horizontal, 14)
        .foregroundStyle(.white)
        .background(.black)
        .clipShape(Capsule())
        .padding()

        assertSnapshot(of: view, as: .image(layout: .fixed(width: 180, height: 64)))
    }

    func test_dynamicIsland_minimal() {
        let view = FocusedTimerLiveActivityMinimalView(
            state: state(phase: .shortBreak, status: .paused),
            referenceDate: referenceDate
        )
        .foregroundStyle(.white)
        .frame(width: 52, height: 52)
        .background(.black)
        .clipShape(Circle())

        assertSnapshot(of: view, as: .image(layout: .fixed(width: 60, height: 60)))
    }

    func test_dynamicIsland_expanded_dark() {
        let view = LiveActivityExpandedBottomView(
            state: state(phase: .longBreak, status: .running),
            isStale: false,
            referenceDate: referenceDate
        )
        .foregroundStyle(.white)
        .background(.black)
        .environment(\.colorScheme, .dark)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 180)))
    }

    private func lockScreen(
        state: FocusedTimerActivityAttributes.ContentState,
        style: UIUserInterfaceStyle
    ) -> some View {
        FocusedTimerLiveActivityLockScreenView(
            state: state,
            isStale: false,
            referenceDate: referenceDate
        )
        .background(style == .dark ? Color.black : Color.white)
        .environment(\.colorScheme, style == .dark ? .dark : .light)
    }

    private func state(
        phase: TimerActivityPhase,
        status: TimerActivityStatus
    ) -> FocusedTimerActivityAttributes.ContentState {
        TimerActivitySnapshot(
            phase: phase,
            status: status,
            totalTime: 1_500,
            remainingTime: 754,
            completedCycles: 2,
            totalCycles: 4,
            capturedAt: referenceDate
        ).contentState
    }
}
