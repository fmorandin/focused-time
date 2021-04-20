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
                    Label(Translation.settingsDismissModalButton, systemImage: ImageNames.closeModal)
                        .labelStyle(IconOnlyLabelStyle())
                        .font(.system(size: 20))
                        .padding(.trailing)
                        .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
                })
                .accessibility(identifier: Identifiers.btnCloseModal)

            }
            .padding(.top)
            .padding(.bottom, 10)

            // The list that contains all the available settings to be defined in the app
            FormView(viewModel: settingsViewModel)

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
