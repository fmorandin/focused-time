//
//  StartTimerIntent.swift
//  Focused Timer
//
//  App Intent that starts the Pomodoro timer via Siri or the Shortcuts app.
//

import AppIntents

struct StartTimerIntent: AppIntent {

    static let title: LocalizedStringResource = "Start Timer"
    static let description: IntentDescription = "Starts or resumes the Focused Timer."

    @Parameter(title: "Timer Type")
    var timerType: TimerType?

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let viewModel = TimerService.shared.timerViewModel

        switch viewModel.timerState {
        case .running:
            return .result(dialog: "Timer is already running.")
        case .paused:
            viewModel.startTimer()
            return .result(dialog: "Timer resumed.")
        case .initial:
            if let requestedType = timerType, viewModel.timerType != requestedType {
                viewModel.resetUpdateTimer()
            }
            viewModel.startTimer()
            let typeName = viewModel.timerType.getCorrectTranslation()
            return .result(dialog: "Started \(typeName) timer.")
        }
    }
}
