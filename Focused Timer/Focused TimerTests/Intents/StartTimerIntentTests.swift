//
//  StartTimerIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("StartTimerIntent")
struct StartTimerIntentTests {

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

    @Test("starts timer when in initial state")
    @MainActor
    func startsTimerFromInitialState() async throws {
        let (viewModel, factory) = makeSetup()

        #expect(viewModel.timerState == .initial)

        let intent = StartTimerIntent()
        _ = try await intent.perform()

        // After startTimer, advance the factory so onStateChange fires
        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("resumes timer when paused")
    @MainActor
    func resumesTimerWhenPaused() async throws {
        let (viewModel, factory) = makeSetup()

        // Start then pause via ViewModel directly
        viewModel.startTimer()
        factory.advance()
        viewModel.pauseTimer()
        #expect(viewModel.timerState == .paused)

        let intent = StartTimerIntent()
        _ = try await intent.perform()

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("returns dialog when already running")
    @MainActor
    func returnsDialogWhenAlreadyRunning() async throws {
        let (viewModel, factory) = makeSetup()

        viewModel.startTimer()
        factory.advance()
        #expect(viewModel.timerState == .running)

        let intent = StartTimerIntent()
        _ = try await intent.perform()

        // Timer should still be running
        #expect(viewModel.timerState == .running)
    }

    @Test("applies requested timer type before starting")
    @MainActor
    func appliesRequestedTimerType() async throws {
        let (viewModel, factory) = makeSetup()
        #expect(viewModel.timerType == .focused)

        var intent = StartTimerIntent()
        intent.timerType = .longBreak
        _ = try await intent.perform()

        factory.advance()
        #expect(viewModel.timerState == .running)
        #expect(viewModel.timerType == .longBreak)
    }
}
