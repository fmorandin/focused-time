//
//  ResetTimerIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("ResetTimerIntent")
struct ResetTimerIntentTests {

    @Test("resets timer to initial state")
    @MainActor
    func resetsToInitialState() async throws {
        let factory = StubRepeatingTimerFactory()
        let viewModel = TimerViewModel(
            timerModel: TimerModelMock(),
            timerFactory: factory,
            isReviewEnabled: false
        )
        let service = MockTimerService(timerViewModel: viewModel)

        viewModel.startTimer()
        factory.advance()
        #expect(viewModel.timerState == .running)

        let intent = ResetTimerIntent()
        _ = try await intent.perform(using: service)

        #expect(viewModel.timerState == .initial)
    }
}
