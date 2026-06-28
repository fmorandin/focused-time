//
//  ToggleSoundIntent.swift
//  Focused Timer
//
//  App Intent that enables or disables the timer sound setting.
//

import AppIntents

struct ToggleSoundIntent: AppIntent {

    static let title: LocalizedStringResource = "Toggle Timer Sound"
    static let description: IntentDescription = "Enables or disables the sound played when the timer finishes."

    @Parameter(title: "Enabled")
    var enabled: Bool

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let settingsModel = SettingsModel()
        settingsModel.saveToggle(value: enabled, for: UserDefaultKeys.playTimerSounds)
        let state = enabled ? "enabled" : "disabled"
        return .result(dialog: "Timer sound \(state).")
    }
}
