//
//  TimerViewLifecycleTests.swift
//  Focused TimerTests
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("TimerView Lifecycle Tests", .serialized)
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

        func saveMoveToBackgroundTime(remainingTime _: Int) {}

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
}
