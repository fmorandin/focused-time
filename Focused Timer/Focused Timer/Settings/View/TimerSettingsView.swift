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
            // Focused time
            HStack {
                withAnimation {
                    Text("settingsFocusDuration")
                        .accessibilityIdentifier(Accessibility.Identifiers.lblFocusDuration)
                        .foregroundStyle(focusedTimerHasValidationErrors ? .red : .primaryFont)
                        .animation(.bouncy(duration: 0.7), value: focusedTimerHasValidationErrors)
                }

                Spacer()

                TextField("", text: $settingsViewModel.focusedTime)
                    .frame(width: 60)
                    .onChange(of: settingsViewModel.focusedTime) {
                        settingsViewModel.focusedTime = String(
                            settingsViewModel.focusedTime.prefix(settingsViewModel.timerLimits)
                        )

                        let focusedTime = Int($settingsViewModel.focusedTime.wrappedValue)
                        guard let focusedTime else {
                            focusedTimerHasValidationErrors = true
                            return
                        }
                        settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: focusedTime)

                        focusedTimerHasValidationErrors = false
                        settingsViewModel.shouldUpdateTimerView = true
                    }
                    .border(focusedTimerHasValidationErrors ? .red : .clear)
                    .animation(.bouncy(duration: 0.7), value: focusedTimerHasValidationErrors)
                    .settingsTextField()
                    .accessibilityIdentifier(Accessibility.Identifiers.txtFocusedTime)
                    .accessibilityLabel(Text("accLabelSettingsFocusDurationTxtFld"))
            }
            .padding(.vertical, 10)

            // Short Break time
            HStack {
                withAnimation {
                    Text("settingsShortBreakDuration")
                        .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakDuration)
                        .foregroundStyle(shortBreakHasValidationErrors ? .red : .primaryFont)
                        .animation(.bouncy(duration: 0.7), value: shortBreakHasValidationErrors)
                }

                Spacer()

                TextField("", text: $settingsViewModel.shortBreakTime)
                    .frame(width: 60)
                    .onChange(of: settingsViewModel.shortBreakTime) {
                        settingsViewModel.shortBreakTime = String(
                            settingsViewModel.shortBreakTime.prefix(settingsViewModel.timerLimits)
                        )

                        let shortBreakTime = Int($settingsViewModel.shortBreakTime.wrappedValue)
                        guard let shortBreakTime else {
                            shortBreakHasValidationErrors = true
                            return
                        }
                        settingsViewModel.saveTime(for: UserDefaultKeys.shortBreakTime, value: shortBreakTime)

                        shortBreakHasValidationErrors = false
                        settingsViewModel.shouldUpdateTimerView = true
                    }
                    .border(shortBreakHasValidationErrors ? .red : .clear)
                    .animation(.bouncy(duration: 0.7), value: shortBreakHasValidationErrors)
                    .settingsTextField()
                    .accessibilityIdentifier(Accessibility.Identifiers.txtShortBreakTime)
                    .accessibilityLabel(Text("accLabelSettingsShortBreakDurationTxtFld"))
            }
            .padding(.vertical, 10)

            // Long Break
            HStack {
                withAnimation {
                    Text("settingsLongBreakDuration")
                        .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakDuration)
                        .foregroundStyle(longBreakHasValidationErrors ? .red : .primaryFont)
                        .animation(.bouncy(duration: 0.7), value: longBreakHasValidationErrors)
                }

                Spacer()

                TextField("", text: $settingsViewModel.longBreak)
                    .frame(width: 60)
                    .onChange(of: settingsViewModel.longBreak) {
                        settingsViewModel.longBreak = String(
                            settingsViewModel.longBreak.prefix(settingsViewModel.timerLimits)
                        )

                        let longBreak = Int($settingsViewModel.longBreak.wrappedValue)
                        guard let longBreak else {
                            longBreakHasValidationErrors = true
                            return
                        }
                        settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: longBreak)

                        longBreakHasValidationErrors = false
                        settingsViewModel.shouldUpdateTimerView = true
                    }
                    .border(longBreakHasValidationErrors ? .red : .clear)
                    .animation(.bouncy(duration: 0.7), value: longBreakHasValidationErrors)
                    .settingsTextField()
                    .accessibilityIdentifier(Accessibility.Identifiers.txtLongBreakTime)
                    .accessibilityLabel(Text("accLabelSettingsLongBreakDurationTxtFld"))
            }
            .padding(.vertical, 10)

            // Number of cycles
            HStack {
                withAnimation {
                    Text("settingsNumberOfCyclesTotal")
                        .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCycles)
                        .foregroundColor(numberOfCyclesHasValidationErrors ? .red : .primaryFont)
                        .animation(.bouncy(duration: 0.7), value: numberOfCyclesHasValidationErrors)
                }

                Spacer()

                TextField("", text: $settingsViewModel.cycleTotal)
                    .frame(width: 60)
                    .onChange(of: settingsViewModel.cycleTotal) {
                        settingsViewModel.cycleTotal = String(
                            settingsViewModel.cycleTotal.prefix(settingsViewModel.numberOfCyclesLimits)
                        )

                        let numberOfCycles = Int($settingsViewModel.cycleTotal.wrappedValue)
                        guard let numberOfCycles else {
                            numberOfCyclesHasValidationErrors = true
                            return
                        }
                        settingsViewModel.saveNumberOfCycles(numberOfCycles)

                        numberOfCyclesHasValidationErrors = false
                        settingsViewModel.shouldUpdateTimerView = true
                    }
                    .border(numberOfCyclesHasValidationErrors ? .red : .clear)
                    .animation(.bouncy(duration: 0.7), value: numberOfCyclesHasValidationErrors)
                    .settingsTextField()
                    .accessibilityIdentifier(Accessibility.Identifiers.txtNumberOfCycles)
                    .accessibilityLabel(Text("accLabelSettingsNbrOfCyclesTotalTxtFld"))
            }
            .padding(.vertical, 10)

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

#Preview {
    Form {
        TimerSettingsView()
    }
}
