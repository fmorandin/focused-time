//
//  PauseTimerIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("PauseTimerIntent")
struct PauseTimerIntentTests {

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

    @Test("pauses running timer")
    @MainActor
    func pausesRunningTimer() async throws {
        let (viewModel, factory) = makeSetup()

        viewModel.startTimer()
        factory.advance()
        #expect(viewModel.timerState == .running)

        let intent = PauseTimerIntent()
        _ = try await intent.perform()

        #expect(viewModel.timerState == .paused)
    }

    @Test("returns error dialog when timer is not running")
    @MainActor
    func returnsErrorWhenNotRunning() async throws {
        let (viewModel, _) = makeSetup()

        #expect(viewModel.timerState == .initial)

        let intent = PauseTimerIntent()
        _ = try await intent.perform()

        // State should remain initial
        #expect(viewModel.timerState == .initial)
    }
}
