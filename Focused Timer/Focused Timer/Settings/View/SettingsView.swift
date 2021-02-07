//
//  SettingsView.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 10/01/21.
//

import SwiftUI

struct SettingsView: View {

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Observed Objects
    @StateObject private var settingsViewModel: SettingsViewModel

    // MARK: Initializer
    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        _settingsViewModel = StateObject(wrappedValue: viewModel)

        UITableView.appearance().backgroundColor = .clear
    }

    // MARK: - Body
    var body: some View {
        VStack {
            /// Top Section with a close button
            HStack {
                Spacer()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: ImageNames.closeModal)
                        .font(.system(size: 20))
                        .padding(.trailing)
                        .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
                }
                .accessibility(identifier: Identifiers.btnCloseModal)
            }
            .padding(.top)
            .padding(.bottom, 10)

            /// The list that contains all the available settings to be defined in the app
            Form {
                VStack {
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
                    .padding(.bottom, 10)

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
                    .padding(.top, 10)
                }
            }
            
            Button(action: {
                let inputFocusedTime = Int(settingsViewModel.focusedTime) ?? 0
                let inputRestTime = Int(settingsViewModel.restTime) ?? 0

                settingsViewModel.saveAndUpdateTimes(focusedIime: inputFocusedTime, restTime: inputRestTime)

                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: ImageNames.saveSettings)
                    .font(.system(size: 20))
                    .foregroundColor((colorScheme == .light ? Color.black : Color.white))
            }
            .accessibility(identifier: Identifiers.btnSaveSettings)
            .padding(.bottom, 50)

        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(["en", "pt"], id: \.self) { id in
                SettingsView()
                    .environment(\.locale, .init(identifier: id))
            }
        }
    }
}
