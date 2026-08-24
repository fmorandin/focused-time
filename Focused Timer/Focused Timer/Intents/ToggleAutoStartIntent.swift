//
//  ToggleAutoStartIntent.swift
//  Focused Timer
//
//  App Intent that enables or disables the auto-start setting.
//

import AppIntents

struct ToggleAutoStartIntent: AppIntent {

    static let title: LocalizedStringResource = "Toggle Auto-Start"
    static let description: IntentDescription = "Enables or disables auto-start between timer sessions."
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Enabled")
    var enabled: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let settingsModel = SettingsModel()
        settingsModel.saveToggle(value: enabled, for: UserDefaultKeys.autoStartToggle)
        let state = enabled ? "enabled" : "disabled"
        return .result(dialog: "Auto-start \(state).")
    }
}
