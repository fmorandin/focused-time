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
                            Image(systemName: ImageNames.closeModal)
                                .font(.system(size: 20))
                                .padding(.trailing)
                                .foregroundColor(.closeButtonColor)
                                .opacity(0.5)
                        }
                        .accessibility(identifier: Accessibility.Identifiers.btnCloseModal)
                    })
                }
                .padding(.top, 30)
                .padding(.bottom, 10)

                // Body
                VStack {
                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.techniqueExplanationTitle)
                                .fontWeight(.bold)
                                .font(.system(.title3, design: .rounded))
                                .padding(.leading)
                                .accessibility(
                                    identifier: Accessibility.Identifiers.lblTechniqueExplanationTitle
                                )
                            Spacer()
                        }

                        Text(Translation.techniqueExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.callout, design: .rounded))
                            .padding([.horizontal, .bottom])
                            .accessibility(identifier: Accessibility.Identifiers.lblTechniqueExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.focusExplanationTitle)
                                .fontWeight(.bold)
                                .font(.system(.title3, design: .rounded))
                                .padding(.leading)
                                .accessibility(identifier: Accessibility.Identifiers.lblFocusExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.focusExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.callout, design: .rounded))
                            .padding([.horizontal, .bottom])
                            .accessibility(identifier: Accessibility.Identifiers.lblFocusExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.shortBreakExplanationTitle)
                                .fontWeight(.bold)
                                .font(.system(.title3, design: .rounded))
                                .padding(.leading)
                                .accessibility(
                                    identifier: Accessibility.Identifiers.lblShortBreakExplanationTitle
                                )

                            Spacer()
                        }

                        Text(Translation.shortBreakExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.callout, design: .rounded))
                            .padding([.horizontal, .bottom])
                            .accessibility(identifier: Accessibility.Identifiers.lblShortBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.longBreakExplanationTitle)
                                .fontWeight(.bold)
                                .font(.system(.title3, design: .rounded))
                                .padding(.leading)
                                .accessibility(
                                    identifier: Accessibility.Identifiers.lblLongBreakExplanationTitle
                                )

                            Spacer()
                        }

                        Text(Translation.longBreakExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.callout, design: .rounded))
                            .padding([.horizontal, .bottom])
                            .accessibility(identifier: Accessibility.Identifiers.lblLongBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.numberOfCyclesExplanationTitle)
                                .fontWeight(.bold)
                                .font(.system(.title3, design: .rounded))
                                .padding(.leading)
                                .accessibility(
                                    identifier: Accessibility.Identifiers.lblNumberOfCyclesExplanationTitle
                                )

                            Spacer()
                        }

                        Text(Translation.numberOfCyclesExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.callout, design: .rounded))
                            .padding([.horizontal, .bottom])
                            .accessibility(identifier: Accessibility.Identifiers.lblNumberOfCyclesExplanation)
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
