//
//  HelpView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 15/03/21.
//

import SwiftUI

struct HelpView: View {

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    // MARK: - View
    var body: some View {
        ScrollView {
            VStack {

                // Top Section with a close button
                HStack {
                    Spacer()

                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        HapticsConstants().impactMedium.impactOccurred()
                    }, label: {
                        HStack {
                            Image(systemName: ImageNames.closeModal)
                                .font(.system(size: 20))
                                .padding(.trailing)
                                .foregroundColor((colorScheme == .light ? Color.black : Color.white))
                                .opacity(0.5)
                        }
                        .accessibility(identifier: Identifiers.btnCloseModal)
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
                                .font(.title3)
                                .padding(.leading)
                                .accessibility(identifier: Identifiers.lblTechniqueExplanationTitle)
                            Spacer()
                        }

                        Text(Translation.techniqueExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                            .accessibility(identifier: Identifiers.lblTechniqueExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.focusExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)
                                .accessibility(identifier: Identifiers.lblFocusExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.focusExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                            .accessibility(identifier: Identifiers.lblFocusExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.shortBreakExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)
                                .accessibility(identifier: Identifiers.lblShortBreakExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.shortBreakExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                            .accessibility(identifier: Identifiers.lblShortBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.longBreakExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)
                                .accessibility(identifier: Identifiers.lblLongBreakExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.longBreakExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                            .accessibility(identifier: Identifiers.lblLongBreakExplanation)
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.numberOfCyclesExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)
                                .accessibility(identifier: Identifiers.lblNumberOfCyclesExplanationTitle)

                            Spacer()
                        }

                        Text(Translation.numberOfCyclesExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                            .accessibility(identifier: Identifiers.lblNumberOfCyclesExplanation)
                    }
                }
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
