//
//  TimerViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 28/09/20.
//

import XCTest
@testable import Focused_Timer

final class TimerViewModelTests: XCTestCase {

    private final class TestRepeatingTimer: RepeatingTimerProtocol {
        private(set) var isInvalidated = false
        private let block: (RepeatingTimerProtocol) -> Void

        init(block: @escaping (RepeatingTimerProtocol) -> Void) {
            self.block = block
        }

        func tick() {
            guard !isInvalidated else { return }
            block(self)
        }

        func invalidate() {
            isInvalidated = true
        }
    }

    private final class TestRepeatingTimerFactory: RepeatingTimerFactoryProtocol {
        private(set) var createdTimers: [TestRepeatingTimer] = []

        func scheduledTimer(
            withTimeInterval _: TimeInterval,
            repeats _: Bool,
            block: @escaping (RepeatingTimerProtocol) -> Void
        ) -> RepeatingTimerProtocol {
            let timer = TestRepeatingTimer(block: block)
            createdTimers.append(timer)
            return timer
        }

        func advance(by ticks: Int = 1) {
            guard ticks > 0 else { return }

            for _ in 0..<ticks {
                let activeTimers = createdTimers.filter { !$0.isInvalidated }
                activeTimers.forEach { $0.tick() }
            }
        }
    }

    private var timerFactory: TestRepeatingTimerFactory!
    private var timerViewModel: TimerViewModel!

    override func setUp() {
        super.setUp()
        timerFactory = TestRepeatingTimerFactory()
        timerViewModel = TimerViewModel(timerModel: TimerModelMock(), timerFactory: timerFactory)
    }

    override func tearDown() {
        timerViewModel = nil
        timerFactory = nil
        super.tearDown()
    }

    func test_StartTimer() {
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.totalNumberOfCycles, 2)

        timerViewModel.startTimer()
        timerFactory.advance()

        XCTAssertEqual(timerViewModel.timerState, .running)
        XCTAssertEqual(timerViewModel.counter, 4)

        // 5 ticks to reach zero + 1 tick to trigger mode change
        timerFactory.advance(by: 5)

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 2)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)
    }

    func test_PauseTimer() {
        XCTAssertEqual(timerViewModel.timerState, .initial)

        timerViewModel.startTimer()
        timerFactory.advance()
        timerViewModel.pauseTimer()

        XCTAssertEqual(timerViewModel.timerState, .paused)
        let pausedCounter = timerViewModel.counter

        // The timer was invalidated, so extra ticks should not change the counter.
        timerFactory.advance(by: 3)
        XCTAssertEqual(timerViewModel.counter, pausedCounter)
    }

    func test_ResetTimer() {
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)

        timerViewModel.startTimer()
        timerFactory.advance(by: 2)

        XCTAssertEqual(timerViewModel.timerState, .running)
        XCTAssertEqual(timerViewModel.counter, 3)

        timerViewModel.resetUpdateTimer()

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.timerType, .focused)
    }

    func test_FocusAndShortBreakTimes() {
        XCTAssertEqual(timerViewModel.timerType, .focused)

        // Focused cycle end -> short break
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 2)
        XCTAssertEqual(timerViewModel.timerType, .shortBreak)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)

        // Short break end -> focused
        timerViewModel.startTimer()
        timerFactory.advance(by: 3)

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerType, .focused)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)
    }

    // swiftlint:disable function_body_length
    func test_CompleteFlowIncludingLongBreak() {
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.totalNumberOfCycles, 2)
        XCTAssertEqual(timerViewModel.timerType, .focused)

        // 1st focused -> short break
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)
        XCTAssertEqual(timerViewModel.timerType, .shortBreak)
        XCTAssertEqual(timerViewModel.counter, 2)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)

        // 1st short break -> focused
        timerViewModel.startTimer()
        timerFactory.advance(by: 3)
        XCTAssertEqual(timerViewModel.timerType, .focused)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)

        // 2nd focused -> long break
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)
        XCTAssertEqual(timerViewModel.timerType, .longBreak)
        XCTAssertEqual(timerViewModel.counter, 3)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 2)

        // Long break -> focused and cycles reset
        timerViewModel.startTimer()
        timerFactory.advance(by: 4)
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.timerType, .focused)
    }
    // swiftlint:enable function_body_length

    func test_MoveAppToForeground_UsesInjectedNowProvider() {
        let savedDate = Date(timeIntervalSince1970: 10)
        let nowDate = Date(timeIntervalSince1970: 14)

        struct TimeAwareTimerModelMock: TimerModelProtocol {
            let savedRemainingTime: Int
            let savedTimestamp: Date

            func getTime(for key: String) -> Int {
                TimerModelMock().getTime(for: key)
            }

            func saveMoveToBackgroundTime(remainingTime _: Int) {}

            func getSavedTimes() -> (Int?, Date?) {
                (savedRemainingTime, savedTimestamp)
            }

            func getNumberOfCycles(for keyName: String) -> String {
                TimerModelMock().getNumberOfCycles(for: keyName)
            }

            func getToggle(for keyName: String) -> Bool {
                TimerModelMock().getToggle(for: keyName)
            }
        }

        let deterministicVM = TimerViewModel(
            timerModel: TimeAwareTimerModelMock(savedRemainingTime: 20, savedTimestamp: savedDate),
            timerFactory: timerFactory,
            nowProvider: { nowDate }
        )

        deterministicVM.startTimer()
        timerFactory.advance() // set state to running

        deterministicVM.moveAppToForeground()

        XCTAssertEqual(deterministicVM.counter, 16)
    }
}
