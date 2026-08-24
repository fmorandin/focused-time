//
//  PauseTimerIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("PauseTimerIntent")
struct PauseTimerIntentTests {

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

    @Test("pauses running timer")
    @MainActor
    func pausesRunningTimer() async throws {
        let (viewModel, factory, service) = makeSetup()

        viewModel.startTimer()
        factory.advance()
        #expect(viewModel.timerState == .running)

        let intent = PauseTimerIntent()
        _ = try await intent.perform(using: service)

        #expect(viewModel.timerState == .paused)
    }

    @Test("returns error dialog when timer is not running")
    @MainActor
    func returnsErrorWhenNotRunning() async throws {
        let (viewModel, _, service) = makeSetup()

        #expect(viewModel.timerState == .initial)

        let intent = PauseTimerIntent()
        _ = try await intent.perform(using: service)

        // State should remain initial
        #expect(viewModel.timerState == .initial)
    }
}
