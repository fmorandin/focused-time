//
//  FocusedTimerFocusFilterIntent.swift
//  Focused Timer
//
//  App Intent that configures the timer when a Focus mode becomes active via iOS Focus Filters.
//

import AppIntents

struct FocusedTimerFocusFilterIntent: SetFocusFilterIntent {

    static let title: LocalizedStringResource = "Configure Focused Timer"
    static let description: IntentDescription = "Auto-configures the timer when a Focus mode is active."
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Configure Focused Timer")
    }

    @Parameter(title: "Timer Type")
    var timerType: TimerType?

    @Parameter(title: "Auto Start Timer", default: false)
    var shouldAutoStart: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        try await perform(using: TimerService.shared)
    }

    @MainActor
    func perform(using timerService: any TimerServiceProtocol) async throws -> some IntentResult {
        let viewModel = timerService.timerViewModel

        guard viewModel.timerState == .initial else {
            return .result()
        }

        if let requestedType = timerType, viewModel.timerType != requestedType {
            viewModel.resetUpdateTimer(to: requestedType)
        }

        if shouldAutoStart {
            viewModel.startTimer()
        }

        return .result()
    }
}
