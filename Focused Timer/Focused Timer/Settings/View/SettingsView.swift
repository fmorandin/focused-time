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
            CloseButton()

            if (shouldDisplayDisclaimer) {
                Text(Translation.settingsWarnReloadMessage)
                    .warningBox()
                    .accessibility(identifier: Accessibility.Identifiers.lblWarnReloadMessage)
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
