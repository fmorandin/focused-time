//
//  ResetSettingsIntent.swift
//  Focused Timer
//
//  App Intent that resets all settings to their default values.
//

import AppIntents

struct ResetSettingsIntent: AppIntent {

    static let title: LocalizedStringResource = "Reset Settings"
    static let description: IntentDescription = "Resets all Focused Timer settings to their default values."

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let viewModel = SettingsViewModel(settingsModel: SettingsModel())
        viewModel.resetToDefault()
        return .result(dialog: "All settings reset to defaults.")
    }
}
