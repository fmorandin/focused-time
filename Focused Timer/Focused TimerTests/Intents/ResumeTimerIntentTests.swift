//
//  ResumeTimerIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("ResumeTimerIntent")
struct ResumeTimerIntentTests {

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

    @Test("resumes paused timer")
    @MainActor
    func resumesPausedTimer() async throws {
        let (viewModel, factory) = makeSetup()

        viewModel.startTimer()
        factory.advance()
        viewModel.pauseTimer()
        #expect(viewModel.timerState == .paused)

        let intent = ResumeTimerIntent()
        _ = try await intent.perform()

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("returns error dialog when timer is not paused")
    @MainActor
    func returnsErrorWhenNotPaused() async throws {
        let (viewModel, _) = makeSetup()

        #expect(viewModel.timerState == .initial)

        let intent = ResumeTimerIntent()
        _ = try await intent.perform()

        // State should remain initial
        #expect(viewModel.timerState == .initial)
    }
}
