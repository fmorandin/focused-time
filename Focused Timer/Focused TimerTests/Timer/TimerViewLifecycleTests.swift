//
//  TimerViewLifecycleTests.swift
//  Focused TimerTests
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("TimerView Lifecycle Tests", .serialized)
@MainActor
struct TimerViewLifecycleTests {

    private final class TimerModelLifecycleMock: TimerModelProtocol {
        var focusedTime = 5
        var shortBreakTime = 2
        var longBreakTime = 3
        var keepScreenOn = true

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

        func saveMoveToBackgroundTime(
            remainingTime _: Int,
            timerType _: TimerType,
            numberOfCompletedCycles _: Int,
            previousPhaseWasFocus _: Bool
        ) {}

        func getSavedTimes() -> (Int?, Date?) {
            (nil, nil)
        }

        func getSavedBackgroundTimerState() -> BackgroundTimerState? { nil }

        func clearSavedBackgroundState() {}

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

    @Test("shouldKeepScreenOn reflects persisted toggle")
    func shouldKeepScreenOnReflectsSavedToggle() {
        let timerModel = TimerModelLifecycleMock()
        timerModel.keepScreenOn = true
        let viewModel = TimerViewModel(timerModel: timerModel)

        #expect(viewModel.shouldKeepScreenOn())
    }

    @Test("idle timer synchronization enables it only while the timer tab is visible")
    func idleTimerSynchronizationUsesPreferenceAndVisibility() {
        let timerModel = TimerModelLifecycleMock()
        let viewModel = TimerViewModel(timerModel: timerModel)
        var receivedValues: [Bool] = []

        timerModel.keepScreenOn = true
        viewModel.synchronizeIdleTimer(isTimerVisible: true) { receivedValues.append($0) }
        viewModel.synchronizeIdleTimer(isTimerVisible: false) { receivedValues.append($0) }

        #expect(receivedValues == [true, false])
    }

    @Test("idle timer synchronization disables it when the preference is off")
    func idleTimerSynchronizationDisablesWhenPreferenceIsOff() {
        let timerModel = TimerModelLifecycleMock()
        timerModel.keepScreenOn = false
        let viewModel = TimerViewModel(timerModel: timerModel)
        var receivedValue: Bool?

        viewModel.synchronizeIdleTimer(isTimerVisible: true) { receivedValue = $0 }

        #expect(receivedValue == false)
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
}
