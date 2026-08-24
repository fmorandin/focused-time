//
//  ResumeTimerIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("ResumeTimerIntent")
struct ResumeTimerIntentTests {

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

    @Test("resumes paused timer")
    @MainActor
    func resumesPausedTimer() async throws {
        let (viewModel, factory, service) = makeSetup()

        viewModel.startTimer()
        factory.advance()
        viewModel.pauseTimer()
        #expect(viewModel.timerState == .paused)

        let intent = ResumeTimerIntent()
        _ = try await intent.perform(using: service)

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("returns error dialog when timer is not paused")
    @MainActor
    func returnsErrorWhenNotPaused() async throws {
        let (viewModel, _, service) = makeSetup()

        #expect(viewModel.timerState == .initial)

        let intent = ResumeTimerIntent()
        _ = try await intent.perform(using: service)

        // State should remain initial
        #expect(viewModel.timerState == .initial)
    }
}
