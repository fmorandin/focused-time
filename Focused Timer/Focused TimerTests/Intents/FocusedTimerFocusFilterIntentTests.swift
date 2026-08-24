//
//  FocusedTimerFocusFilterIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("FocusedTimerFocusFilterIntent", .serialized)
struct FocusedTimerFocusFilterIntentTests {

    @MainActor
    // swiftlint:disable:next large_tuple
    private func makeSetup() -> (TimerViewModel, StubRepeatingTimerFactory, MockTimerService) {
        let factory = StubRepeatingTimerFactory()
        let viewModel = TimerViewModel(
            timerModel: TimerModelMock(),
            timerFactory: factory,
            isReviewEnabled: false
        )
        return (viewModel, factory, MockTimerService(timerViewModel: viewModel))
    }

    @Test("starts timer when shouldAutoStart is true and timer is initial")
    @MainActor
    func startsTimerWhenAutoStartIsTrue() async throws {
        let (viewModel, factory, service) = makeSetup()
        #expect(viewModel.timerState == .initial)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = true
        _ = try await intent.perform(using: service)

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("does not start timer when shouldAutoStart is false")
    @MainActor
    func doesNotStartTimerWhenAutoStartIsFalse() async throws {
        let (viewModel, _, service) = makeSetup()
        #expect(viewModel.timerState == .initial)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = false
        _ = try await intent.perform(using: service)

        #expect(viewModel.timerState == .initial)
    }

    @Test("does not interrupt a running timer")
    @MainActor
    func doesNotInterruptRunningTimer() async throws {
        let (viewModel, factory, service) = makeSetup()
        viewModel.startTimer()
        factory.advance()
        #expect(viewModel.timerState == .running)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = true
        _ = try await intent.perform(using: service)

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("does not interrupt a paused timer")
    @MainActor
    func doesNotInterruptPausedTimer() async throws {
        let (viewModel, factory, service) = makeSetup()
        viewModel.startTimer()
        factory.advance()
        viewModel.pauseTimer()
        #expect(viewModel.timerState == .paused)

        let intent = FocusedTimerFocusFilterIntent()
        intent.shouldAutoStart = true
        _ = try await intent.perform(using: service)

        #expect(viewModel.timerState == .paused)
    }

    @Test("configures the requested timer type without auto-starting")
    @MainActor
    func configuresRequestedTimerType() async throws {
        let (viewModel, _, service) = makeSetup()
        let intent = FocusedTimerFocusFilterIntent()
        intent.timerType = .longBreak
        intent.shouldAutoStart = false

        _ = try await intent.perform(using: service)

        #expect(viewModel.timerType == .longBreak)
        #expect(viewModel.counter == 3)
        #expect(viewModel.timerState == .initial)
    }
}
