//
//  GetTimerStatusIntent.swift
//  Focused Timer
//
//  App Intent that reports the current timer status (type, state, time remaining, cycles).
//

import AppIntents

struct GetTimerStatusIntent: AppIntent {

    static let title: LocalizedStringResource = "Get Timer Status"
    static let description: IntentDescription = "Returns the current timer status."
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        try await perform(using: TimerService.shared)
    }

    @MainActor
    func perform(
        using timerService: any TimerServiceProtocol
    ) async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let viewModel = timerService.timerViewModel
        let typeName = viewModel.timerType.getCorrectTranslation()

        let stateText: String
        switch viewModel.timerState {
        case .running:
            stateText = "running"
        case .paused:
            stateText = "paused"
        case .initial:
            stateText = "stopped"
        }

        let completedCycles = viewModel.numberOfCompletedCycles
        let totalCycles = viewModel.totalNumberOfCycles
        let timeRemaining = viewModel.countTime

        let status = "\(typeName) timer is \(stateText). " +
            "Time remaining: \(timeRemaining). " +
            "Cycles: \(completedCycles) of \(totalCycles)."

        return .result(value: status, dialog: "\(status)")
    }
}
