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
            }

            Section {
                Text("focusExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblFocusExplanation)
            }

            Section {
                Text("shortBreakExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakExplanation)
            }

            Section {
                Text("longBreakExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakExplanation)
            }

            Section {
                Text("numberOfCyclesExplanation")
                    .helpSectionText()
                    .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesExplanation)
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
