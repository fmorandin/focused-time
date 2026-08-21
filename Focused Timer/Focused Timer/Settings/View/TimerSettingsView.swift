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
        category: String(describing: TimerSettingsView.self)
    )

    @Bindable var settingsViewModel: SettingsViewModel

    // MARK: - Validators

    @State private var focusedTimerHasValidationErrors: Bool = false
    @State private var shortBreakHasValidationErrors: Bool = false
    @State private var longBreakHasValidationErrors: Bool = false
    @State private var numberOfCyclesHasValidationErrors: Bool = false

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        Self.logger.notice("🛠 Initializing Timer Settings View.")
        self.settingsViewModel = viewModel
    }

    // MARK: - View Body

    var body: some View {
        Section {
            TimerSettingRow(
                label: "settingsFocusDuration",
                labelIdentifier: Accessibility.Identifiers.lblFocusDuration,
                fieldLabel: "accLabelSettingsFocusDurationTxtFld",
                fieldIdentifier: Accessibility.Identifiers.txtFocusedTime,
                text: $settingsViewModel.focusedTime,
                hasValidationErrors: $focusedTimerHasValidationErrors,
                maximumLength: settingsViewModel.timerLimits
            ) { value in
                settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: value)
                settingsViewModel.shouldUpdateTimerView = true
            }

            TimerSettingRow(
                label: "settingsShortBreakDuration",
                labelIdentifier: Accessibility.Identifiers.lblShortBreakDuration,
                fieldLabel: "accLabelSettingsShortBreakDurationTxtFld",
                fieldIdentifier: Accessibility.Identifiers.txtShortBreakTime,
                text: $settingsViewModel.shortBreakTime,
                hasValidationErrors: $shortBreakHasValidationErrors,
                maximumLength: settingsViewModel.timerLimits
            ) { value in
                settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: value)
                settingsViewModel.shouldUpdateTimerView = true
            }

            TimerSettingRow(
                label: "settingsLongBreakDuration",
                labelIdentifier: Accessibility.Identifiers.lblLongBreakDuration,
                fieldLabel: "accLabelSettingsLongBreakDurationTxtFld",
                fieldIdentifier: Accessibility.Identifiers.txtLongBreakTime,
                text: $settingsViewModel.longBreak,
                hasValidationErrors: $longBreakHasValidationErrors,
                maximumLength: settingsViewModel.timerLimits
            ) { value in
                settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: value)
                settingsViewModel.shouldUpdateTimerView = true
            }

            TimerSettingRow(
                label: "settingsNumberOfCyclesTotal",
                labelIdentifier: Accessibility.Identifiers.lblNumberOfCycles,
                fieldLabel: "accLabelSettingsNbrOfCyclesTotalTxtFld",
                fieldIdentifier: Accessibility.Identifiers.txtNumberOfCycles,
                text: $settingsViewModel.cycleTotal,
                hasValidationErrors: $numberOfCyclesHasValidationErrors,
                maximumLength: settingsViewModel.numberOfCyclesLimits
            ) { value in
                settingsViewModel.saveNumberOfCycles(value)
                settingsViewModel.shouldUpdateTimerView = true
            }

        } header: {
            Text("settingsSectionTimersName")
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)
        ) { _ in
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil
                )
            }
        }
        .font(.system(.body, design: .rounded))
    }
}

private struct TimerSettingRow: View {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let label: LocalizedStringKey
    let labelIdentifier: String
    let fieldLabel: LocalizedStringKey
    let fieldIdentifier: String
    @Binding var text: String
    @Binding var hasValidationErrors: Bool
    let maximumLength: Int
    let saveValue: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    settingLabel
                    Spacer()
                    settingTextField
                }

                VStack(alignment: .leading, spacing: 8) {
                    settingLabel
                    settingTextField
                }
            }

            if hasValidationErrors {
                Label("settingsInvalidNumberMessage", systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblInvalidNumberMessage)
            }
        }
        .padding(.vertical, 10)
        .animation(reduceMotion ? nil : .bouncy(duration: 0.7), value: hasValidationErrors)
    }

    private var settingLabel: some View {
        Text(label)
            .foregroundStyle(.primaryFont)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier(labelIdentifier)
    }

    private var settingTextField: some View {
        TextField("", text: $text)
            .onChange(of: text) {
                text = String(text.prefix(maximumLength))

                guard let value = Int(text) else {
                    hasValidationErrors = true
                    return
                }

                hasValidationErrors = false
                saveValue(value)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(hasValidationErrors ? Color.red : Color.clear, lineWidth: 2)
                    .allowsHitTesting(false)
            }
            .settingsTextField()
            .frame(width: dynamicTypeSize.isAccessibilitySize ? 96 : 72)
            .accessibilityIdentifier(fieldIdentifier)
            .accessibilityLabel(Text(fieldLabel))
            .accessibilityValue(
                hasValidationErrors ? Text("settingsInvalidNumberAccessibilityValue") : Text(verbatim: text)
            )
            .accessibilityHint(Text("settingsNumericFieldHint"))
    }
}

#Preview {
    Form {
        TimerSettingsView()
    }
}
