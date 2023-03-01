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

    // MARK: - Environment

    @Environment(\.presentationMode) var presentationMode

    // MARK: - View
    var body: some View {
        ScrollView {
            VStack {
                // Top Section with a close button
                HStack {
                    Spacer()

                    Button(action: {
                        Self.logger.notice("❌ Closing Help View.")
                        presentationMode.wrappedValue.dismiss()
                        HapticsConstants().impactMedium.impactOccurred()
                    }, label: {
                        HStack {
                            Label(Translation.dismissModalButton, systemImage: ImageNames.closeModal)
                                .iconNoText()
                        }
                        .accessibilityIdentifier(Accessibility.Identifiers.btnCloseModal)
                    })
                }
                .padding(.top, 30)
                .padding(.bottom, 10)

                // Body
                VStack {
                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.techniqueExplanationTitle)
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblTechniqueExplanationTitle)
                            Spacer()
                        }

                        Text(Translation.techniqueExplanation)
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblTechniqueExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.focusExplanationTitle)
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblFocusExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.focusExplanation)
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblFocusExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.shortBreakExplanationTitle)
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.shortBreakExplanation)
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblShortBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.longBreakExplanationTitle)
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.longBreakExplanation)
                            .helpSectionText()
                            .accessibilityIdentifier(Accessibility.Identifiers.lblLongBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.numberOfCyclesExplanationTitle)
                                .helpSectionTitle()
                                .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.numberOfCyclesExplanation)
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
