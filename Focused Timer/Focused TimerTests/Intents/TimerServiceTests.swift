//
//  TimerServiceTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("TimerService")
@MainActor
struct TimerServiceTests {

    @Test("setSharedForTesting replaces the shared instance")
    func setSharedForTestingReplacesInstance() {
        let original = TimerService.shared

        let viewModel = TimerViewModel(
            timerModel: TimerModelMock(),
            timerFactory: StubRepeatingTimerFactory(),
            isReviewEnabled: false
        )
        let mockService = MockTimerService(timerViewModel: viewModel)

        TimerService.setSharedForTesting(mockService)
        #expect(TimerService.shared === mockService)

        // Restore for other tests
        TimerService.setSharedForTesting(original)
    }

    @Test("shared instance exposes a TimerViewModel")
    func sharedExposesViewModel() {
        let service = TimerService.shared
        let viewModel = service.timerViewModel
        #expect(viewModel.timerState == .initial || viewModel.timerState == .running || viewModel.timerState == .paused)
    }
}
