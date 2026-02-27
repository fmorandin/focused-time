//
//  AppSettingsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/12/22.
//

import SwiftUI
import os

struct AppSettingsView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FormView.self)
    )

    @StateObject private var settingsViewModel: SettingsViewModel

    @State private var keepScreenOnDisclaimerAlert = false

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        Self.logger.notice("🛠 Initializing App Settings View.")
        _settingsViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View Body

    var body: some View {
        Section(header: Text("settingsSectionAppName")) {
            // Auto Start
            Toggle("settingsAutoStart", isOn: $settingsViewModel.isAutoStartEnabled)
                .onChange(of: settingsViewModel.isAutoStartEnabled) { _, newValue in
                    settingsViewModel.saveToggles(
                        for: UserDefaultKeys.autoStartToggle,
                        value: newValue
                    )
                }
                .accessibilityIdentifier(Accessibility.Identifiers.tgAutoStart)
                .accessibilityLabel(Text("accLabelSettingsAutoStartToggle"))
                .padding(.vertical, 10)

            // Play sounds
            Toggle("settingsPlayTimerSounds", isOn: $settingsViewModel.isPlaySoundEnabled)
                .onChange(of: settingsViewModel.isPlaySoundEnabled) { _, newValue in
                    settingsViewModel.saveToggles(
                        for: UserDefaultKeys.playTimerSounds
                        , value: newValue
                    )
                }
                .accessibilityIdentifier(Accessibility.Identifiers.tgPlaySounds)
                .accessibilityLabel(Text("accLabelSettingsPlaySoundsToggle"))
                .padding(.vertical, 10)

            // Keep screen on
            Toggle("settingsKeepScreenOn", isOn: $settingsViewModel.keepScreenOn)
                .onChange(of: settingsViewModel.keepScreenOn) { _, newValue in
                    settingsViewModel.saveToggles(
                        for: UserDefaultKeys.keepScreenOn,
                        value: newValue
                    )
                    keepScreenOnDisclaimerAlert = true
                }
                .accessibilityIdentifier(Accessibility.Identifiers.tgKeepScreenOn)
                .accessibilityLabel(Text("accLabelSettingsKeepScreenOnToggle"))
                .alert(isPresented: $keepScreenOnDisclaimerAlert, content: {
                    Alert(
                        title: Text("warningAlertTitle"),
                        message: Text("settingsKeepScreenOnDisclaimer"),
                        dismissButton: .default(Text("OK")))
                })
                .padding(.vertical, 10)
        }
        .font(.system(.body, design: .rounded))
    }
}

struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(displayWarning: true)
    }
}
