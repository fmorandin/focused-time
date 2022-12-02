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

    @State private var shouldUpdateTimerView: Bool
    @State private var resetDefaultValuesAlert = false
    @State private var keepScreenOnDisclaimerAlert = false

    private let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    private let window: UIWindow?

    // MARK: - Initializer

    init(viewModel: SettingsViewModel = SettingsViewModel(settingsModel: SettingsModel())) {

        Self.logger.notice("🛠 Initializing Form View.")

        _settingsViewModel = StateObject(wrappedValue: viewModel)

        UITableView.appearance().backgroundColor = .clear

        _shouldUpdateTimerView = State(wrappedValue: false)

        window = windowScene?.windows.first
    }

    // MARK: - Body

    var body: some View {
        Form {
            // Input settings
            Section(header: Text(Translation.settingsSectionTimersName)) {
                // Focused time
                HStack {
                    Text(Translation.settingsFocusDuration)
                        .accessibility(identifier: Accessibility.Identifiers.lblFocusDuration)

                    Spacer()

                    TextField("", text: $settingsViewModel.focusedTime, onEditingChanged: { isEditing in
                        if !isEditing {
                            let focusedTime = Int($settingsViewModel.focusedTime.wrappedValue) ?? 0
                            settingsViewModel.saveTime(for: UserDefaultKeys.focusedTime, value: focusedTime)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtFocusedTime)
                    .accessibility(label: Text(Translation.AccLabel.accLabelSettingsFocusDurationTxtFld))
                }
                .padding(.vertical, 10)

                // Short Break time
                HStack {
                    Text(Translation.settingsShortBreakDuration)
                        .accessibility(identifier: Accessibility.Identifiers.lblShortBreakDuration)

                    Spacer()

                    TextField("", text: $settingsViewModel.shortBreakTime, onEditingChanged: { isEditing in
                        if !isEditing {
                            let shortBreakTime = Int($settingsViewModel.shortBreakTime.wrappedValue) ?? 0
                            settingsViewModel.saveTime(
                                for: UserDefaultKeys.shortBreakTime,
                                value: shortBreakTime
                            )

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtShortBreakTime)
                    .accessibility(label: Text(Translation.AccLabel.accLabelSettingsShortBreakDurationTxtFld))
                }
                .padding(.vertical, 10)

                // Long Break
                HStack {
                    Text(Translation.settingsLongBreakDuration)
                        .accessibility(identifier: Accessibility.Identifiers.lblLongBreakDuration)

                    Spacer()

                    TextField("", text: $settingsViewModel.longBreak, onEditingChanged: { isEditing in
                        if !isEditing {
                            let longBreak = Int($settingsViewModel.longBreak.wrappedValue) ?? 0
                            settingsViewModel.saveTime(for: UserDefaultKeys.longBreakTime, value: longBreak)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtLongBreakTime)
                    .accessibility(label: Text(Translation.AccLabel.accLabelSettingsLongBreakDurationTxtFld))
                }
                .padding(.vertical, 10)

                // Number of cycles
                HStack {
                    Text(Translation.settingsNumberOfCyclesTotal)
                        .accessibility(identifier: Accessibility.Identifiers.lblNumberOfCycles)

                    Spacer()

                    TextField("", text: $settingsViewModel.cycleTotal, onEditingChanged: { isEditing in
                        if !isEditing {
                            let numberOfCycles = Int($settingsViewModel.cycleTotal.wrappedValue) ?? 0
                            settingsViewModel.saveNumberOfCycles(numberOfCycles)

                            shouldUpdateTimerView = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: Accessibility.Identifiers.txtNumberOfCycles)
                    .accessibility(label: Text(Translation.AccLabel.accLabelSettingsNbrOfCyclesTotalTxtFld))
                }
                .padding(.vertical, 10)
            }

            // Toggle settings
            Section(header: Text(Translation.settingsSectionAppName)) {
                // Auto Start
                HStack {
                    Text(Translation.settingsAutoStart)
                        .accessibility(identifier: Accessibility.Identifiers.lblAutoStart)

                    Spacer()

                    Toggle("", isOn: $settingsViewModel.isAutoStartEnabled)
                        .onChange(of: settingsViewModel.isAutoStartEnabled, perform: { value in
                            settingsViewModel.saveToggles(
                                for: UserDefaultKeys.autoStartToggle,
                                value: value
                            )
                        })
                        .accessibility(identifier: Accessibility.Identifiers.tgAutoStart)
                        .accessibility(label: Text(Translation.AccLabel.accLabelSettingsAutoStartToggle))
                }
                .padding(.vertical, 10)

                // Play sounds
                HStack {
                    Text(Translation.settingsPlayTimerSounds)
                        .accessibility(identifier: Accessibility.Identifiers.lblPlaySounds)

                    Spacer()

                    Toggle("", isOn: $settingsViewModel.isPlaySoundEnabled)
                        .onChange(of: settingsViewModel.isPlaySoundEnabled, perform: { value in
                            settingsViewModel.saveToggles(
                                for: UserDefaultKeys.playTimerSounds,
                                value: value
                            )
                        })
                        .accessibility(identifier: Accessibility.Identifiers.tgPlaySounds)
                        .accessibility(label: Text(Translation.AccLabel.accLabelSettingsPlaySoundsToggle))
                }
                .padding(.vertical, 10)

                // Keep screen on
                HStack {
                    Text(Translation.settingsKeepScreenOn)
                        .accessibility(identifier: Accessibility.Identifiers.lblKeepScreenOn)

                    Spacer()

                    Toggle("", isOn: $settingsViewModel.keepScreenOn)
                        .onChange(of: settingsViewModel.keepScreenOn, perform: { value in
                            settingsViewModel.saveToggles(
                                for: UserDefaultKeys.keepScreenOn,
                                value: value
                            )
                            keepScreenOnDisclaimerAlert = true
                        })
                        .alert(isPresented: $keepScreenOnDisclaimerAlert, content: {
                            Alert(
                                title: Text(Translation.warningAlertTitle),
                                message: Text(Translation.settingsKeepScreenOnDisclaimer),
                                dismissButton: .default(Text("OK")))
                        })
                        .accessibility(identifier: Accessibility.Identifiers.tgKeepScreenOn)
                        .accessibility(label: Text(Translation.AccLabel.accLabelSettingsKeepScreenOnToggle))
                }
                .padding(.vertical, 10)
            }

            Section {
                HStack {
                    Spacer()

                    Button(action: {
                        resetDefaultValuesAlert.toggle()
                    }, label: {
                        Text(Translation.resetSettingsDefaultValue)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(Color.red)
                    .accessibility(identifier: Accessibility.Identifiers.btnResetSettingsDefault)
                    .alert(isPresented: $resetDefaultValuesAlert, content: {
                        Alert(
                            title: Text(Translation.resetSettingsAlertTitle),
                            message: Text(Translation.resetSettingsAlertMessage),
                            primaryButton: .default(Text("OK"),
                                                    action: {
                                                        shouldUpdateTimerView = true
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
                            completion: settingsViewModel.actionSheet
                        )
                    }, label: {
                        HStack {
                            Text(Translation.shareAppTitle)
                            Image(systemName: ImageNames.share)
                        }
                    })
                    .accessibility(identifier: Accessibility.Identifiers.btnShareApp)
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.vertical, 10)
                .font(.callout)
                .foregroundColor(.secondary)
            }
        }
        .onDisappear(perform: {
            if shouldUpdateTimerView {
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
