//
//  FocusedTimerFocusFilterIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("FocusedTimerFocusFilterIntent", .serialized)
struct FocusedTimerFocusFilterIntentTests {

    private func makeSetup() -> (TimerViewModel, StubRepeatingTimerFactory) {
        let factory = StubRepeatingTimerFactory()
        let viewModel = TimerViewModel(
            timerModel: TimerModelMock(),
            timerFactory: factory,
            isReviewEnabled: false
        )
        TimerService.setSharedForTesting(MockTimerService(timerViewModel: viewModel))
        return (viewModel, factory)
    }

    @Test("starts timer when shouldAutoStart is true and timer is initial")
    @MainActor
    func startsTimerWhenAutoStartIsTrue() async throws {
        let (viewModel, factory) = makeSetup()
        #expect(viewModel.timerState == .initial)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = true
        _ = try await intent.perform()

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("does not start timer when shouldAutoStart is false")
    @MainActor
    func doesNotStartTimerWhenAutoStartIsFalse() async throws {
        let (viewModel, _) = makeSetup()
        #expect(viewModel.timerState == .initial)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = false
        _ = try await intent.perform()

        #expect(viewModel.timerState == .initial)
    }

    @Test("does not interrupt a running timer")
    @MainActor
    func doesNotInterruptRunningTimer() async throws {
        let (viewModel, factory) = makeSetup()
        viewModel.startTimer()
        factory.advance()
        #expect(viewModel.timerState == .running)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = true
        _ = try await intent.perform()

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("does not interrupt a paused timer")
    @MainActor
    func doesNotInterruptPausedTimer() async throws {
        let (viewModel, factory) = makeSetup()
        viewModel.startTimer()
        factory.advance()
        viewModel.pauseTimer()
        #expect(viewModel.timerState == .paused)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = true
        _ = try await intent.perform()

        #expect(viewModel.timerState == .paused)
    }

    @Test("applies requested timer type when timer is initial")
    @MainActor
    func appliesRequestedTimerTypeWhenInitial() async throws {
        let (viewModel, _) = makeSetup()
        #expect(viewModel.timerType == .focused)

        var intent = FocusedTimerFocusFilterIntent()
        intent.timerType = .shortBreak
        intent.shouldAutoStart = false
        _ = try await intent.perform()

        #expect(viewModel.timerState == .initial)
        #expect(viewModel.timerType == .shortBreak)
    }
}
