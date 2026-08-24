//
//  GetTimerStatusIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("GetTimerStatusIntent")
struct GetTimerStatusIntentTests {

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

    @Test("returns correct status for initial state")
    @MainActor
    func returnsInitialStatus() async throws {
        let (_, _, service) = makeSetup()

        let intent = GetTimerStatusIntent()
        let result = try await intent.perform(using: service)

        let status = try #require(result.value)
        #expect(status.contains("stopped"))
    }

    @Test("returns correct status for running state")
    @MainActor
    func returnsRunningStatus() async throws {
        let (viewModel, factory, service) = makeSetup()

        viewModel.startTimer()
        factory.advance()

        let intent = GetTimerStatusIntent()
        let result = try await intent.perform(using: service)

        let status = try #require(result.value)
        #expect(status.contains("running"))
    }

    @Test("includes cycle count in response")
    @MainActor
    func includesCycleCount() async throws {
        let (_, _, service) = makeSetup()

        let intent = GetTimerStatusIntent()
        let result = try await intent.perform(using: service)

        let status = try #require(result.value)
        #expect(status.contains("Cycles:"))
    }
}
