//
//  HelpView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 15/03/21.
//

import SwiftUI
import os

struct HelpView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HelpView.self)
    )

    // MARK: - View

    var body: some View {
        List {
            Section {
                Text("techniqueExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblTechniqueExplanation)
            } header: {
                Text("techniqueExplanationTitle")
                    .helpSectionTitle()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblTechniqueExplanationTitle)
            }

            Section {
                Text("focusExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblFocusExplanation)
            } header: {
                Text("focusExplanationTitle")
                    .helpSectionTitle()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblFocusExplanationTitle)
            }

            Section {
                Text("shortBreakExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakExplanation)
            } header: {
                Text("shortBreakExplanationTitle")
                    .helpSectionTitle()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakExplanationTitle)
            }

            Section {
                Text("longBreakExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakExplanation)
            } header: {
                Text("longBreakExplanationTitle")
                    .helpSectionTitle()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakExplanationTitle)
            }

            Section {
                Text("numberOfCyclesExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesExplanation)
            } header: {
                Text("numberOfCyclesExplanationTitle")
                    .helpSectionTitle()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesExplanationTitle)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("helpNavigationTitle")
        .onAppear {
            Self.logger.notice("🆘 Help View opened.")
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HelpView()
        }
    }
}
