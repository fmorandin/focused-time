//
//  SettingsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 10/01/21.
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
    }

    // MARK: - Body

    var body: some View {
        VStack {
            // Top Section with a close button
            HStack {
                Spacer()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    SharedConstants().impactMedium.impactOccurred()
                }, label: {
                    HStack {
                        Image(systemName: ImageNames.closeModal)
                            .font(.system(size: 20))
                            .padding(.trailing)
                            .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
                    }
                    .accessibility(identifier: Identifiers.btnCloseModal)
                })

            }
            .padding(.top)
            .padding(.bottom, 10)

            // The list that contains all the available settings to be defined in the app
            FormView(viewModel: settingsViewModel)

            Button(action: {
                let inputFocusedTime = Int(settingsViewModel.focusedTime) ?? 0
                let inputRestTime = Int(settingsViewModel.restTime) ?? 0
                let inputLongBreak = Int(settingsViewModel.longBreak) ?? 0
                let inputNumberOfCycles = Int(settingsViewModel.cycleTotal) ?? 0

                let screenOn = settingsViewModel.screenOn
                let autoStart = settingsViewModel.autoStart

                settingsViewModel.saveAndUpdateTimes(
                    focusedIime: inputFocusedTime,
                    restTime: inputRestTime,
                    longBreak: inputLongBreak
                )
                settingsViewModel.saveNumberOfCycles(inputNumberOfCycles)

                settingsViewModel.saveToggles(screenOn: screenOn, autoStart: autoStart)

                self.presentationMode.wrappedValue.dismiss()
                SharedConstants().impactMedium.impactOccurred()
            }, label: {
                HStack {
                    Image(systemName: ImageNames.saveSettings)
                        .font(.system(size: 20))
                        .foregroundColor((colorScheme == .light ? Color.black : Color.white))
                }
                .accessibility(identifier: Identifiers.btnSaveSettings)
                .padding(.bottom, 50)
            })

        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}
#endif

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
