//
//  AppSettingsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/12/22.
//

import SwiftUI
import UIKit
import os

struct AppSettingsView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppSettingsView.self)
    )

    @Bindable var settingsViewModel: SettingsViewModel

    @State private var keepScreenOnDisclaimerAlert = false

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        Self.logger.notice("🛠 Initializing App Settings View.")
        self.settingsViewModel = viewModel
    }

    // MARK: - View Body

    var body: some View {
        Section(header: Text("settingsSectionAppName").padding(.leading, -12)) {
            // Starting timer type
            Picker("settingsStartingTimerType", selection: $settingsViewModel.startingTimerType) {
                ForEach([TimerType.focused, .shortBreak, .longBreak], id: \.self) { timerType in
                    Text(timerType.getCorrectTranslation()).tag(timerType)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: settingsViewModel.startingTimerType) { _, newValue in
                settingsViewModel.saveStartingTimerType(newValue)
            }
            .accessibilityIdentifier(Accessibility.Identifiers.pkStartingTimerType)
            .padding(.vertical, 10)

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

            // Enable notifications
            Toggle("settingsEnableNotifications", isOn: $settingsViewModel.isNotificationsEnabled)
                .onChange(of: settingsViewModel.isNotificationsEnabled) { _, newValue in
                    settingsViewModel.saveToggles(
                        for: UserDefaultKeys.enableNotifications,
                        value: newValue
                    )
                }
                .accessibilityIdentifier(Accessibility.Identifiers.tgEnableNotifications)
                .accessibilityLabel(Text("accLabelSettingsEnableNotificationsToggle"))
                .disabled(settingsViewModel.isNotificationsDeniedBySystem)
                .padding(.vertical, 10)

            if settingsViewModel.isNotificationsDeniedBySystem {
                VStack(alignment: .leading, spacing: 8) {
                    Label("settingsNotificationsDeniedMessage", systemImage: "bell.slash.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier(Accessibility.Identifiers.lblNotificationsDeniedMessage)

                    Button("settingsNotificationsOpenSettings") {
                        Task {
                            await settingsViewModel.openNotificationSettings()
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier(Accessibility.Identifiers.btnOpenNotificationsSettings)
                }
                .padding(.vertical, 4)
            }
        }
        .font(.system(.body, design: .rounded))
        .task {
            await settingsViewModel.checkNotificationAuthorizationStatus()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
        ) { _ in
            Task {
                await settingsViewModel.checkNotificationAuthorizationStatus()
            }
        }
    }
}

struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(displayWarning: true)
    }
}
