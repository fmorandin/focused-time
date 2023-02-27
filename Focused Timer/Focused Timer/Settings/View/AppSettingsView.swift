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

    init(viewModel: SettingsViewModel) {

        Self.logger.notice("🛠 Initializing App Settings View.")

        _settingsViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View Body

    var body: some View {
        Section(header: Text(Translation.settingsSectionAppName)) {
            // Auto Start
            HStack {
                Text(Translation.settingsAutoStart)
                    .accessibility(identifier: Accessibility.Identifiers.lblAutoStart)

                Spacer()

                Toggle("", isOn: $settingsViewModel.isAutoStartEnabled)
                    .onChange(of: settingsViewModel.isAutoStartEnabled, perform: { value in
                        settingsViewModel.saveToggles(
                            for: UserDefaultKeys.autoStartToggle,
                            value: value
                        )
                    })
                    .accessibility(identifier: Accessibility.Identifiers.tgAutoStart)
                    .accessibility(label: Text(Translation.AccLabel.accLabelSettingsAutoStartToggle))
            }
            .padding(.vertical, 10)

            // Play sounds
            HStack {
                Text(Translation.settingsPlayTimerSounds)
                    .accessibility(identifier: Accessibility.Identifiers.lblPlaySounds)

                Spacer()

                Toggle("", isOn: $settingsViewModel.isPlaySoundEnabled)
                    .onChange(of: settingsViewModel.isPlaySoundEnabled, perform: { value in
                        settingsViewModel.saveToggles(
                            for: UserDefaultKeys.playTimerSounds,
                            value: value
                        )
                    })
                    .accessibility(identifier: Accessibility.Identifiers.tgPlaySounds)
                    .accessibility(label: Text(Translation.AccLabel.accLabelSettingsPlaySoundsToggle))
            }
            .padding(.vertical, 10)

            // Keep screen on
            HStack {
                Text(Translation.settingsKeepScreenOn)
                    .accessibility(identifier: Accessibility.Identifiers.lblKeepScreenOn)

                Spacer()

                Toggle("", isOn: $settingsViewModel.keepScreenOn)
                    .onChange(of: settingsViewModel.keepScreenOn, perform: { value in
                        settingsViewModel.saveToggles(
                            for: UserDefaultKeys.keepScreenOn,
                            value: value
                        )
                        keepScreenOnDisclaimerAlert = true
                    })
                    .alert(isPresented: $keepScreenOnDisclaimerAlert, content: {
                        Alert(
                            title: Text(Translation.warningAlertTitle),
                            message: Text(Translation.settingsKeepScreenOnDisclaimer),
                            dismissButton: .default(Text("OK")))
                    })
                    .accessibility(identifier: Accessibility.Identifiers.tgKeepScreenOn)
                    .accessibility(label: Text(Translation.AccLabel.accLabelSettingsKeepScreenOnToggle))
            }
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
