//
//  Form.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/03/21.
//

import SwiftUI

struct FormView: View {

    // MARK: - Private Variables

    @StateObject private var settingsViewModel: SettingsViewModel

    @State private var shouldUpdateTimerView: Bool
    @State private var resetDefaultValuesAlert: Bool = false

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        _settingsViewModel = StateObject(wrappedValue: viewModel)

        UITableView.appearance().backgroundColor = .clear

        _shouldUpdateTimerView = State(wrappedValue: false)
    }

    // MARK: - Body

    var body: some View {
        Form {
            // Input settings
            Section(header: Text(Translation.settingsSectionTimersName)) {
                // Focused time
                HStack {
                    Text(Translation.settingsFocusDuration)
                        .accessibility(identifier: Accessibility.Identifiers.lblFocusDuration)

                    Spacer()

                    TextField("", text: $settingsViewModel.focusedTime, onEditingChanged: { isEditing in
                        if !isEditing {
                            let focusedTime = Int($settingsViewModel.focusedTime.wrappedValue) ?? 0
                            settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: focusedTime)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtFocusedTime)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)

                // Short Break time
                HStack {
                    Text(Translation.settingsShortBreakDuration)
                        .accessibility(identifier: Accessibility.Identifiers.lblShortBreakDuration)

                    Spacer()

                    TextField("", text: $settingsViewModel.shortBreakTime, onEditingChanged: { isEditing in
                        if !isEditing {
                            let shortBreakTime = Int($settingsViewModel.shortBreakTime.wrappedValue) ?? 0
                            settingsViewModel.saveTime(
                                for: UserDefaultKeys.shortBreakTime,
                                value: shortBreakTime
                            )

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtShortBreakTime)
                }
                .padding(.bottom, 10)
                .padding(.top, 10)

                // Long Break
                HStack {
                    Text(Translation.settingsLongBreakDuration)
                        .accessibility(identifier: Accessibility.Identifiers.lblLongBreakDuration)

                    Spacer()

                    TextField("", text: $settingsViewModel.longBreak, onEditingChanged: { isEditing in
                        if !isEditing {
                            let longBreak = Int($settingsViewModel.longBreak.wrappedValue) ?? 0
                            settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: longBreak)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtLongBreakTime)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)

                // Number of cycles
                HStack {
                    Text(Translation.settingsNumberOfCyclesTotal)
                        .accessibility(identifier: Accessibility.Identifiers.lblNumberOfCycles)

                    Spacer()

                    TextField("", text: $settingsViewModel.cycleTotal, onEditingChanged: { isEditing in
                        if !isEditing {
                            let numberOfCycles = Int($settingsViewModel.cycleTotal.wrappedValue) ?? 0
                            settingsViewModel.saveNumberOfCycles(numberOfCycles)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtNumberOfCycles)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }

            // Toggle settings
            Section(header: Text(Translation.settingsSectionAppName)) {
                // Auto Start
                HStack {
                    Text(Translation.settingsAutoStart)
                        .accessibility(identifier: Accessibility.Identifiers.lblAutoStart)

                    Spacer()

                    Toggle("", isOn: $settingsViewModel.autoStart)
                        .onChange(of: settingsViewModel.autoStart, perform: { value in
                            settingsViewModel.saveToggles(autoStart: value)
                            shouldUpdateTimerView = true
                        })
                        .accessibility(identifier: Accessibility.Identifiers.tgAutoStart)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }

            Section {
                HStack {
                    Spacer()

                    Button(action: {}, label: {
                        Text(Translation.resetSettingsDefaultValue)
                    })
                    .foregroundColor(Color.red)
                    .accessibility(identifier: Accessibility.Identifiers.btnResetSettingsDefault)
                    .onTapGesture {
                        resetDefaultValuesAlert.toggle()
                    }
                    .alert(isPresented: $resetDefaultValuesAlert, content: {
                        Alert(
                            title: Text(Translation.resetSettingsAlertTitle),
                            message: Text(Translation.resetSettingsAlertMessage),
                            primaryButton: .default(Text("OK"),
                                                    action: {
                                                        shouldUpdateTimerView = true
                                                        settingsViewModel.resetToDefault()
                                                        HapticsConstants().impactHeavy.impactOccurred()
                                                    }),
                            secondaryButton: .cancel())
                    })

                    Spacer()
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
        }
        .onDisappear(perform: {
            if shouldUpdateTimerView {
                NotificationCenter.default.post(name: .updateTimerView, object: nil)
            }
        })
    }
}

struct Form_Previews: PreviewProvider {
    static var previews: some View {
        FormView()

    }
}
