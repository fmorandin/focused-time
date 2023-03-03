//
//  TimerSettingsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 04/12/22.
//

import SwiftUI
import os

struct TimerSettingsView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FormView.self)
    )

    @StateObject private var settingsViewModel: SettingsViewModel

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        Self.logger.notice("🛠 Initializing Timer Settings View.")
        _settingsViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View Body

    var body: some View {
        Section(header: Text(Translation.settingsSectionTimersName)) {
            // Focused time
            HStack {
                Text(Translation.settingsFocusDuration)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblFocusDuration)

                Spacer()

                TextField("", text: $settingsViewModel.focusedTime, onEditingChanged: { isEditing in
                    if !isEditing {
                        let focusedTime = Int($settingsViewModel.focusedTime.wrappedValue) ?? 0
                        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: focusedTime)

                        settingsViewModel.shouldUpdateTimerView = true
                    }
                })
                .settingsTextField()
                .accessibilityIdentifier(Accessibility.Identifiers.txtFocusedTime)
                .accessibilityLabel(Text(Translation.AccLabel.accLabelSettingsFocusDurationTxtFld))
            }
            .padding(.vertical, 10)

            // Short Break time
            HStack {
                Text(Translation.settingsShortBreakDuration)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakDuration)

                Spacer()

                TextField("", text: $settingsViewModel.shortBreakTime, onEditingChanged: { isEditing in
                    if !isEditing {
                        let shortBreakTime = Int($settingsViewModel.shortBreakTime.wrappedValue) ?? 0
                        settingsViewModel.saveTime(
                            for: UserDefaultKeys.shortBreakTime,
                            value: shortBreakTime
                        )

                        settingsViewModel.shouldUpdateTimerView = true
                    }
                })
                .settingsTextField()
                .accessibilityIdentifier(Accessibility.Identifiers.txtShortBreakTime)
                .accessibilityLabel(Text(Translation.AccLabel.accLabelSettingsShortBreakDurationTxtFld))
            }
            .padding(.vertical, 10)

            // Long Break
            HStack {
                Text(Translation.settingsLongBreakDuration)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakDuration)

                Spacer()

                TextField("", text: $settingsViewModel.longBreak, onEditingChanged: { isEditing in
                    if !isEditing {
                        let longBreak = Int($settingsViewModel.longBreak.wrappedValue) ?? 0
                        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: longBreak)

                        settingsViewModel.shouldUpdateTimerView = true
                    }
                })
                .settingsTextField()
                .accessibilityIdentifier(Accessibility.Identifiers.txtLongBreakTime)
                .accessibilityLabel(Text(Translation.AccLabel.accLabelSettingsLongBreakDurationTxtFld))
            }
            .padding(.vertical, 10)

            // Number of cycles
            HStack {
                Text(Translation.settingsNumberOfCyclesTotal)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCycles)

                Spacer()

                TextField("", text: $settingsViewModel.cycleTotal, onEditingChanged: { isEditing in
                    if !isEditing {
                        let numberOfCycles = Int($settingsViewModel.cycleTotal.wrappedValue) ?? 0
                        settingsViewModel.saveNumberOfCycles(numberOfCycles)

                        settingsViewModel.shouldUpdateTimerView = true
                    }
                })
                .settingsTextField()
                .accessibilityIdentifier(Accessibility.Identifiers.txtNumberOfCycles)
                .accessibilityLabel(Text(Translation.AccLabel.accLabelSettingsNbrOfCyclesTotalTxtFld))
            }
            .padding(.vertical, 10)
        }
        .font(.system(.body, design: .rounded))
    }
}

struct TimerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(displayWarning: true)
    }
}
