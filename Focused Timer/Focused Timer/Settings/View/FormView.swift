//
//  Form.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/03/21.
//

import SwiftUI

struct FormView: View {

    @StateObject private var settingsViewModel: SettingsViewModel

    @State private var shouldUpdateTimerView: Bool

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        _settingsViewModel = StateObject(wrappedValue: viewModel)

        UITableView.appearance().backgroundColor = .clear

        _shouldUpdateTimerView = State(wrappedValue: false)
    }

    var body: some View {
        Form {
            // Input settings
            Section(header: Text(Translation.settingsSectionTimersName)) {
                // Focused time
                HStack {
                    Text(Translation.settingsFocusDuration)
                        .accessibility(identifier: Identifiers.lblFocusDuration)

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
                    .accessibility(identifier: Identifiers.txtFocusedTime)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)

                // Resting time
                HStack {
                    Text(Translation.settingsRestDuration)
                        .accessibility(identifier: Identifiers.lblRestDuration)

                    Spacer()

                    TextField("", text: $settingsViewModel.restTime, onEditingChanged: { isEditing in
                        if !isEditing {
                            let restTime = Int($settingsViewModel.restTime.wrappedValue) ?? 0
                            settingsViewModel.saveTime(for: UserDefaultKeys.restTime, value: restTime)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Identifiers.txtRestTime)
                }
                .padding(.bottom, 10)
                .padding(.top, 10)

                // Long Break
                HStack {
                    Text(Translation.settingsLongBreak)
                        .accessibility(identifier: Identifiers.lblLongBreak)

                    Spacer()

                    TextField("", text: $settingsViewModel.longBreak, onEditingChanged: { isEditing in
                        if !isEditing {
                            let longBreak = Int($settingsViewModel.longBreak.wrappedValue) ?? 0
                            settingsViewModel.saveTime(for: UserDefaultKeys.longBreak, value: longBreak)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Identifiers.txtLongBreak)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)

                // Number of cycles
                HStack {
                    Text(Translation.settingsCyclesTotal)
                        .accessibility(identifier: Identifiers.lblCycleTotal)

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
                    .accessibility(identifier: Identifiers.txtCycleTotal)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }

            // Toggle settings
            Section(header: Text(Translation.settingsSectionAppName)) {
                // Auto Start
                HStack {
                    Text(Translation.settingsAutoStart)
                        .accessibility(identifier: Identifiers.lblAutoStart)

                    Spacer()

                    Toggle("", isOn: $settingsViewModel.autoStart)
                        .onChange(of: settingsViewModel.autoStart, perform: { value in
                            settingsViewModel.saveToggles(autoStart: value)
                            shouldUpdateTimerView = true
                        })
                        .accessibility(identifier: Identifiers.tgAutoStart)
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
