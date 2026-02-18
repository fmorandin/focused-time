//
//  TimerViewLifecycleTests.swift
//  Focused TimerTests
//

import XCTest
@testable import Focused_Timer

final class TimerViewLifecycleTests: XCTestCase {

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
    }

    func test_ShouldKeepScreenOn_ReflectsSavedToggle() {
        let timerModel = TimerModelLifecycleMock()
        timerModel.keepScreenOn = true
        let viewModel = TimerViewModel(timerModel: timerModel)

        XCTAssertTrue(viewModel.shouldKeepScreenOn())
    }

    func test_ShouldDisplaySettingsAlert_DependsOnTimerState() {
        let viewModel = TimerViewModel(timerModel: TimerModelLifecycleMock())

        XCTAssertFalse(viewModel.shouldDisplaySettingsAlert())

        viewModel.timerState = .running
        XCTAssertTrue(viewModel.shouldDisplaySettingsAlert())

        viewModel.timerState = .paused
        XCTAssertTrue(viewModel.shouldDisplaySettingsAlert())
    }

    func test_ResetUpdateTimer_UsesLatestFocusedTimeFromModel() {
        let timerModel = TimerModelLifecycleMock()
        timerModel.focusedTime = 10
        let viewModel = TimerViewModel(timerModel: timerModel)

        viewModel.startTimer()
        viewModel.resetUpdateTimer()

        XCTAssertEqual(viewModel.counter, 10)
        XCTAssertEqual(viewModel.totalTime, 10)
        XCTAssertEqual(viewModel.timerState, .initial)
        XCTAssertEqual(viewModel.timerType, .focused)
    }
}
