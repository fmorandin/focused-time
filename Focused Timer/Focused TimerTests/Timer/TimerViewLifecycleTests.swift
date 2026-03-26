//
//  TimerViewLifecycleTests.swift
//  Focused TimerTests
//

import Foundation
import SwiftUI
import Testing
@testable import Focused_Timer

@Suite("TimerView Lifecycle Tests", .serialized)
struct TimerViewLifecycleTests {

    private final class TimerModelLifecycleMock: TimerModelProtocol {
        var focusedTime = 5
        var shortBreakTime = 2
        var longBreakTime = 3
        var keepScreenOn = true
        private(set) var savedBackgroundTimestampCount = 0

        func getTime(for keyName: String) -> Int {
            switch keyName {
            case UserDefaultKeys.focusedTime:
                return focusedTime
            case UserDefaultKeys.shortBreakTime:
                return shortBreakTime
            case UserDefaultKeys.longBreakTime:
                return longBreakTime
            default:
                return 0
            }
        }

        func saveMoveToBackgroundTime(remainingTime _: Int) {}
        func saveBackgroundTimestamp() {
            savedBackgroundTimestampCount += 1
        }
        func getBackgroundTimestamp() -> Date? { nil }

        func getSavedTimes() -> (Int?, Date?) {
            (nil, nil)
        }

        func getNumberOfCycles(for _: String) -> String {
            "2"
        }

        func getToggle(for keyName: String) -> Bool {
            switch keyName {
            case UserDefaultKeys.keepScreenOn:
                return keepScreenOn
            case UserDefaultKeys.autoStartToggle, UserDefaultKeys.playTimerSounds:
                return false
            default:
                return false
            }
        }

        func getStartingTimerType() -> TimerType {
            .focused
        }
    }

    private final class NotificationManagerLifecycleSpy: LocalNotificationManaging {
        private(set) var clearCalls = 0

        func clearScheduledNotifications() {
            clearCalls += 1
        }

        func scheduleLocalNotification(remainingTime _: Double, timerType _: TimerType) {}
    }

    private final class TimerServiceSpy: TimerServiceProtocol, @unchecked Sendable {
        let timerViewModel: TimerViewModel

        init(timerViewModel: TimerViewModel) {
            self.timerViewModel = timerViewModel
        }
    }

    @Test("shouldKeepScreenOn reflects persisted toggle")
    func shouldKeepScreenOnReflectsSavedToggle() {
        let timerModel = TimerModelLifecycleMock()
        timerModel.keepScreenOn = true
        let viewModel = TimerViewModel(timerModel: timerModel)

        #expect(viewModel.shouldKeepScreenOn())
    }

    @Test("shouldDisplaySettingsAlert depends on timer state")
    func shouldDisplaySettingsAlertDependsOnTimerState() {
        let viewModel = TimerViewModel(timerModel: TimerModelLifecycleMock())

        #expect(!viewModel.shouldDisplaySettingsAlert())

        viewModel.timerState = .running
        #expect(viewModel.shouldDisplaySettingsAlert())

        viewModel.timerState = .paused
        #expect(viewModel.shouldDisplaySettingsAlert())
    }

    @Test("resetUpdateTimer reloads latest focused time")
    func resetUpdateTimerUsesLatestFocusedTimeFromModel() {
        let timerModel = TimerModelLifecycleMock()
        timerModel.focusedTime = 10
        let viewModel = TimerViewModel(timerModel: timerModel)

        viewModel.startTimer()
        viewModel.resetUpdateTimer()

        #expect(viewModel.counter == 10)
        #expect(viewModel.totalTime == 10)
        #expect(viewModel.timerState == .initial)
        #expect(viewModel.timerType == .focused)
    }

    @Test("ContentView scenePhase background triggers timer background sync")
    func contentViewBackgroundPhaseTriggersBackgroundSync() {
        let timerModel = TimerModelLifecycleMock()
        let viewModel = TimerViewModel(timerModel: timerModel)
        let contentView = ContentView(timerService: TimerServiceSpy(timerViewModel: viewModel))

        contentView.handleScenePhaseChange(.background)

        #expect(timerModel.savedBackgroundTimestampCount == 1)
    }

    @Test("ContentView scenePhase active triggers timer foreground sync")
    func contentViewActivePhaseTriggersForegroundSync() {
        let notificationManager = NotificationManagerLifecycleSpy()
        let viewModel = TimerViewModel(
            timerModel: TimerModelLifecycleMock(),
            localNotificationManager: notificationManager
        )
        let contentView = ContentView(timerService: TimerServiceSpy(timerViewModel: viewModel))

        contentView.handleScenePhaseChange(.active)

        #expect(notificationManager.clearCalls == 1)
    }

    @Test("ContentView scenePhase inactive does not trigger background or foreground sync")
    func contentViewInactivePhaseDoesNotTriggerSync() {
        let timerModel = TimerModelLifecycleMock()
        let notificationManager = NotificationManagerLifecycleSpy()
        let viewModel = TimerViewModel(
            timerModel: timerModel,
            localNotificationManager: notificationManager
        )
        let contentView = ContentView(timerService: TimerServiceSpy(timerViewModel: viewModel))

        contentView.handleScenePhaseChange(.inactive)

        #expect(timerModel.savedBackgroundTimestampCount == 0)
        #expect(notificationManager.clearCalls == 0)
    }
}
