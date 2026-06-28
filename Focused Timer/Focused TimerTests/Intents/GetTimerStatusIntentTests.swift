//
//  GetTimerStatusIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("GetTimerStatusIntent")
struct GetTimerStatusIntentTests {

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

    @Test("returns correct status for initial state")
    @MainActor
    func returnsInitialStatus() async throws {
        let (_, _) = makeSetup()

        let intent = GetTimerStatusIntent()
        let result = try await intent.perform()

        let status = try #require(result.value)
        #expect(status.contains("stopped"))
    }

    @Test("returns correct status for running state")
    @MainActor
    func returnsRunningStatus() async throws {
        let (viewModel, factory) = makeSetup()

        viewModel.startTimer()
        factory.advance()

        let intent = GetTimerStatusIntent()
        let result = try await intent.perform()

        let status = try #require(result.value)
        #expect(status.contains("running"))
    }

    @Test("includes cycle count in response")
    @MainActor
    func includesCycleCount() async throws {
        let (_, _) = makeSetup()

        let intent = GetTimerStatusIntent()
        let result = try await intent.perform()

        let status = try #require(result.value)
        #expect(status.contains("Cycles:"))
    }
}
