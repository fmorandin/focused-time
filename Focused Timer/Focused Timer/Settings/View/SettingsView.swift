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

    // MARK: - State

    @State private var settingsViewModel: SettingsViewModel

    // MARK: - Private Var

    private var shouldDisplayDisclaimer: Bool

    // MARK: Initializer

    init(
        viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel()),
        displayWarning: Bool = false
    ) {
        Self.logger.notice("🛠 Initializing Settings View.")
        _settingsViewModel = State(wrappedValue: viewModel)
        self.shouldDisplayDisclaimer = displayWarning
    }

    // MARK: - Body

    var body: some View {
        FormView(viewModel: settingsViewModel, displayWarning: shouldDisplayDisclaimer)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("settingsNavigationTitle")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Self.logger.notice("⚙️ Settings View opened.")
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(displayWarning: true)
        }
        .environment(Router())
    }
}
