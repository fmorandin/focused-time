//
//  Form.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/03/21.
//

import SwiftUI

struct FormView: View {

    @StateObject private var settingsViewModel: SettingsViewModel

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        _settingsViewModel = StateObject(wrappedValue: viewModel)

        UITableView.appearance().backgroundColor = .clear
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

                    TextField("", text: $settingsViewModel.focusedTime)
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

                    TextField("", text: $settingsViewModel.restTime)
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

                    TextField("", text: $settingsViewModel.longBreak)
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

                    TextField("", text: $settingsViewModel.cycleTotal)
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
                        .accessibility(identifier: Identifiers.tgAutoStart)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
        }
    }
}

struct Form_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
