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
        ScrollView {
            VStack {
                // Top Section with a close button
                CloseButton()

                // Body
                VStack {
                    VStack(spacing: 5) {
                        HStack {
                            Text("techniqueExplanationTitle")
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblTechniqueExplanationTitle)
                            Spacer()
                        }

                        Text("techniqueExplanation")
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblTechniqueExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text("focusExplanationTitle")
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblFocusExplanationTitle)

                            Spacer()
                        }

                        Text("focusExplanation")
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblFocusExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text("shortBreakExplanationTitle")
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakExplanationTitle)

                            Spacer()
                        }

                        Text("shortBreakExplanation")
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text("longBreakExplanationTitle")
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakExplanationTitle)

                            Spacer()
                        }

                        Text("longBreakExplanation")
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text("numberOfCyclesExplanationTitle")
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesExplanationTitle)

                            Spacer()
                        }

                        Text("numberOfCyclesExplanation")
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesExplanation)
                    }
                }
            }
            .onAppear {
                Self.logger.notice("🆘 Help View opened.")
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
