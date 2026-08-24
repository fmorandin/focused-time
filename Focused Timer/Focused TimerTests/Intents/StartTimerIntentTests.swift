//
//  StartTimerIntentTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@Suite("StartTimerIntent")
struct StartTimerIntentTests {

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

    @Test("starts timer when in initial state")
    @MainActor
    func startsTimerFromInitialState() async throws {
        let (viewModel, factory, service) = makeSetup()

        #expect(viewModel.timerState == .initial)

        let intent = StartTimerIntent()
        _ = try await intent.perform(using: service)

        // After startTimer, advance the factory so onStateChange fires
        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("resumes timer when paused")
    @MainActor
    func resumesTimerWhenPaused() async throws {
        let (viewModel, factory, service) = makeSetup()

        // Start then pause via ViewModel directly
        viewModel.startTimer()
        factory.advance()
        viewModel.pauseTimer()
        #expect(viewModel.timerState == .paused)

        let intent = StartTimerIntent()
        _ = try await intent.perform(using: service)

        factory.advance()
        #expect(viewModel.timerState == .running)
    }

    @Test("returns dialog when already running")
    @MainActor
    func returnsDialogWhenAlreadyRunning() async throws {
        let (viewModel, factory, service) = makeSetup()

        viewModel.startTimer()
        factory.advance()
        #expect(viewModel.timerState == .running)

        let intent = StartTimerIntent()
        _ = try await intent.perform(using: service)

        // Timer should still be running
        #expect(viewModel.timerState == .running)
    }

    @Test("starts the requested timer type")
    @MainActor
    func startsRequestedTimerType() async throws {
        let (viewModel, _, service) = makeSetup()
        let intent = StartTimerIntent()
        intent.timerType = .shortBreak

        _ = try await intent.perform(using: service)

        #expect(viewModel.timerType == .shortBreak)
        #expect(viewModel.counter == 2)
        #expect(viewModel.timerState == .running)
    }
}
