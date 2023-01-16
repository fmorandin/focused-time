//
//  SettingsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 10/01/21.
//

import SwiftUI
import os

struct SettingsView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SettingsView.self)
    )

    // MARK: - Environment

    @Environment(\.presentationMode) var presentationMode

    // MARK: - Observed Objects

    @StateObject private var settingsViewModel: SettingsViewModel

    // MARK: - Private Var

    private var shouldDisplayDisclaimer: Bool

    // MARK: Initializer

    init(
        viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel()),
        displayWarning: Bool = false
    ) {

        Self.logger.notice("🛠 Initializing Settings View.")

        _settingsViewModel = StateObject(wrappedValue: viewModel)

        self.shouldDisplayDisclaimer = displayWarning
    }

    // MARK: - Body

    var body: some View {
        VStack {
            // Top Section with a close button
            HStack {
                Spacer()

                Button(action: {
                    Self.logger.notice("❌ Closing Settings View.")
                    self.presentationMode.wrappedValue.dismiss()
                    HapticsConstants().impactMedium.impactOccurred()
                }, label: {
                    Label(Translation.settingsDismissModalButton, systemImage: ImageNames.closeModal)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 20))
                        .padding(.trailing)
                        .foregroundColor(.closeButtonColor)
                        .opacity(0.5)
                })
                .accessibility(identifier: Accessibility.Identifiers.btnCloseModal)

            }
            .padding(.top, 30)
            .padding(.bottom, 10)

            if (shouldDisplayDisclaimer) {
                Text(Translation.settingsWarnReloadMessage)
                    .foregroundColor(.white)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .padding(.all, 10)
                    .background(.red)
                    .accessibility(identifier: Accessibility.Identifiers.lblWarnReloadMessage)
                    .padding(.horizontal, 1)
            }

            // The list that contains all the available settings to be defined in the app
            FormView(viewModel: settingsViewModel)

        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .navigationBarHidden(true)
        .onAppear {
            Self.logger.notice("⚙️ Settings View opened.")
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
        SettingsView(displayWarning: true)
    }
}
