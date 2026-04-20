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

    let settingsViewModel: SettingsViewModel
    let displayWarning: Bool

    @State private var resetDefaultValuesAlert = false

    // MARK: - Initializer

    init(
        viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel()),
        displayWarning: Bool = false
    ) {
        Self.logger.notice("🛠 Initializing Form View.")
        self.settingsViewModel = viewModel
        self.displayWarning = displayWarning
    }

    // MARK: - Body

    var body: some View {
        Form {
            if displayWarning {
                Section {
                    Text("settingsWarnReloadMessage")
                        .warningBox()
                        .accessibility(identifier: Accessibility.Identifiers.lblWarnReloadMessage)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }

            // Input settings
            TimerSettingsView(viewModel: settingsViewModel)

            // Toggle settings
            AppSettingsView(viewModel: settingsViewModel)

            Section {
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
                        settingsViewModel.shareSheet()
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
        .contentMargins(.top, 16, for: .scrollContent)
        .onChange(of: router.selectedTab) { _, newTab in
            if newTab != .settings && self.settingsViewModel.shouldUpdateTimerView {
                router.signalSettingsChanged()
                self.settingsViewModel.shouldUpdateTimerView = false
            }
        }
    }
}

struct Form_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
            .environment(Router())
    }
}
