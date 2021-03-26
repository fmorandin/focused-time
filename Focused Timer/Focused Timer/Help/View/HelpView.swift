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
                        SharedConstants().impactMedium.impactOccurred()
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
                .padding(.top)
                .padding(.bottom, 10)

                VStack {
                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.techniqueExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)
                            Spacer()
                        }

                        Text(Translation.techniqueExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.focusExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)

                            Spacer()
                        }

                        Text(Translation.focusExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                    }

                    VStack(spacing: 5) {
                        HStack {
                            Text(Translation.restExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)

                            Spacer()
                        }

                        Text(Translation.restExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.longBreakExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)

                            Spacer()
                        }

                        Text(Translation.longBreakExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
                    }

                    VStack(spacing: 5) {
                        HStack {

                            Text(Translation.numberOfCyclesExplanationTitle)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.leading)

                            Spacer()
                        }

                        Text(Translation.numberOfCyclesExplanation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .padding([.leading, .trailing, .bottom])
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
