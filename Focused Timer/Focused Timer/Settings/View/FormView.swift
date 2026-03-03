//
//  FormView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 22/03/21.
//

import SwiftUI
import os

struct FormView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FormView.self)
    )

    // MARK: - Environment

    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss

    let settingsViewModel: SettingsViewModel

    @State private var resetDefaultValuesAlert = false

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {
        Self.logger.notice("🛠 Initializing Form View.")
        self.settingsViewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        Form {
            // Input settings
            TimerSettingsView(viewModel: settingsViewModel)

            // Toggle settings
            AppSettingsView(viewModel: settingsViewModel)

            Section {
                HStack {
                    Spacer()

                    Button(action: {
                        resetDefaultValuesAlert.toggle()
                    }, label: {
                        Text("resetSettingsDefaultValue")
                            .font(.system(.body, design: .rounded))
                    })
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    .accessibility(identifier: Accessibility.Identifiers.btnResetSettingsDefault)
                    .alert(isPresented: $resetDefaultValuesAlert, content: {
                        Alert(
                            title: Text("resetSettingsAlertTitle"),
                            message: Text("resetSettingsAlertMessage"),
                            primaryButton: .default(Text("OK"),
                                                    action: {
                                                        settingsViewModel.shouldUpdateTimerView = true
                                                        settingsViewModel.resetToDefault()
                                                        HapticsConstants().impactHeavy.impactOccurred()
                                                    }),
                            secondaryButton: .cancel())
                    })

                    Spacer()
                }
                .padding(.vertical, 10)
            }

            Section {
                HStack {
                    Text("\(Text("appVersionTitle")): \(settingsViewModel.appVersionNumber)")
                        .font(.system(.footnote, design: .rounded))
                        .accessibility(identifier: Accessibility.Identifiers.lblAppVersion)

                    Spacer()

                    Divider()

                    Spacer()

                    Button(action: {
                        dismiss()
                        // UIKitShareService grabs the key window lazily after the
                        // sheet finishes its dismissal animation.
                        Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(300))
                            settingsViewModel.shareSheet()
                        }
                    }, label: {
                        HStack {
                            Text("shareAppTitle")
                                .font(.system(.footnote, design: .rounded))
                            Image(systemName: ImageNames.share)
                        }
                    })
                    .accessibility(identifier: Accessibility.Identifiers.btnShareApp)
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 10)
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.secondary)
            }
        }
        .onDisappear(perform: {
            if settingsViewModel.shouldUpdateTimerView {
                router.signalSettingsChanged()
            }
        })
    }
}

struct Form_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
            .environment(Router())
    }
}
