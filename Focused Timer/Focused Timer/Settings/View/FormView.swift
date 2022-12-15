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

    @StateObject private var settingsViewModel: SettingsViewModel

    @State private var resetDefaultValuesAlert = false

    private let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    private let window: UIWindow?

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {

        Self.logger.notice("🛠 Initializing Form View.")

        _settingsViewModel = StateObject(wrappedValue: viewModel)

        UITableView.appearance().backgroundColor = .clear

        window = windowScene?.windows.first
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
                        Text(Translation.resetSettingsDefaultValue)
                    })
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    .accessibility(identifier: Accessibility.Identifiers.btnResetSettingsDefault)
                    .alert(isPresented: $resetDefaultValuesAlert, content: {
                        Alert(
                            title: Text(Translation.resetSettingsAlertTitle),
                            message: Text(Translation.resetSettingsAlertMessage),
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
                    Text("\(Text(Translation.appVersionTitle)): \(settingsViewModel.appVersionNumber)")
                        .accessibility(identifier: Accessibility.Identifiers.lblAppVersion)

                    Spacer()

                    Divider()

                    Spacer()

                    Button(action: {
                        window?.rootViewController?.dismiss(
                            animated: true,
                            completion: settingsViewModel.shareSheet
                        )
                    }, label: {
                        HStack {
                            Text(Translation.shareAppTitle)
                            Image(systemName: ImageNames.share)
                        }
                    })
                    .accessibility(identifier: Accessibility.Identifiers.btnShareApp)
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 10)
                .font(.callout)
                .foregroundColor(.secondary)
            }
        }
        .onDisappear(perform: {
            if settingsViewModel.shouldUpdateTimerView {
                NotificationCenter.default.post(name: .updateTimerView, object: nil)
            }
        })
    }
}

struct Form_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
            .preferredColorScheme(.dark)
    }
}
