//
//  TimerTypePillViewTests.swift
//  Focused TimerTests
//
//  Tests for TimerTypePillView — verifies that the ViewModel property the pill
//  reads (timerType) carries the correct value at each phase of the timer
//  lifecycle, and that it maps to the expected localized label.
//
//  Animation and transition behaviour are not testable at the unit level;
//  those are covered by manual/UI testing.
//

import Foundation
import Testing
@testable import Focused_Timer

// MARK: - Test doubles

private final class PillTestTimer: RepeatingTimerProtocol {
    private(set) var isInvalidated = false
    private let block: (any RepeatingTimerProtocol) -> Void

    init(block: @escaping (any RepeatingTimerProtocol) -> Void) {
        self.block = block
    }

    func fire() {
        guard !isInvalidated else { return }
        block(self)
    }

    func invalidate() {
        isInvalidated = true
    }
}

private final class PillTestTimerFactory: RepeatingTimerFactoryProtocol {
    private(set) var timers: [PillTestTimer] = []

    func scheduledTimer(
        withTimeInterval _: TimeInterval,
        repeats _: Bool,
        block: @escaping (any RepeatingTimerProtocol) -> Void
    ) -> any RepeatingTimerProtocol {
        let timer = PillTestTimer(block: block)
        timers.append(timer)
        return timer
    }

    func advance(by ticks: Int) {
        for _ in 0..<ticks {
            timers.filter { !$0.isInvalidated }.forEach { $0.fire() }
        }
    }
}

// MARK: - Tests

@Suite("TimerTypePillView Tests", .serialized)
struct TimerTypePillViewTests {

    // MARK: - Initial state

    @Test("pill displays focus label on launch")
    func initialStateShowsFocusLabel() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())

        #expect(viewModel.timerType == .focused)
        #expect(
            TimerType.getCorrectTranslation(viewModel.timerType)() ==
            LocalizedStringResource("focusName", table: "Localizable")
        )
    }

    // MARK: - Phase transitions

    @Test("pill transitions to short break label after focus session completes")
    func pillShowsShortBreakAfterFocusCompletes() {
        let factory = PillTestTimerFactory()
        let viewModel = TimerViewModel(timerModel: TimerModelMock(), timerFactory: factory)

        viewModel.startTimer()
        factory.advance(by: 6) // TimerModelMock.focusedTime = 5; 6th tick triggers phase change

        #expect(viewModel.timerType == .shortBreak)
        #expect(
            TimerType.getCorrectTranslation(viewModel.timerType)() ==
            LocalizedStringResource("shortBreakName", table: "Localizable")
        )
    }

    @Test("pill returns to focus label after short break completes")
    func pillShowsFocusAfterShortBreakCompletes() {
        let factory = PillTestTimerFactory()
        let viewModel = TimerViewModel(timerModel: TimerModelMock(), timerFactory: factory)

        viewModel.startTimer()
        factory.advance(by: 6)  // complete focus (focusedTime = 5)
        viewModel.startTimer()
        factory.advance(by: 3)  // complete short break (shortBreakTime = 2)

        #expect(viewModel.timerType == .focused)
        #expect(
            TimerType.getCorrectTranslation(viewModel.timerType)() ==
            LocalizedStringResource("focusName", table: "Localizable")
        )
    }

    @Test("pill shows long break label after all cycles complete")
    func pillShowsLongBreakAfterAllCyclesComplete() {
        let factory = PillTestTimerFactory()
        let viewModel = TimerViewModel(timerModel: TimerModelMock(), timerFactory: factory)
        // TimerModelMock returns numberOfCycles = "2", so two focus sessions trigger long break

        viewModel.startTimer()
        factory.advance(by: 6)  // focus 1 → short break
        viewModel.startTimer()
        factory.advance(by: 3)  // short break → focus 2
        viewModel.startTimer()
        factory.advance(by: 6)  // focus 2 → long break

        #expect(viewModel.timerType == .longBreak)
        #expect(
            TimerType.getCorrectTranslation(viewModel.timerType)() ==
            LocalizedStringResource("longBreakName", table: "Localizable")
        )
    }
}
