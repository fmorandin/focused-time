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
        VStack {
            // Top Section with a close button
            HStack {
                Spacer()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Image(systemName: ImageNames.closeModal)
                            .font(.system(size: 20))
                            .padding(.trailing)
                            .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
                    }
                    .accessibility(identifier: Identifiers.btnCloseModal)
                })

            }
            .padding(.top)
            .padding(.bottom, 10)

            Spacer()

            Text("Help screen")

            Spacer()
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(["en", "pt"], id: \.self) { id in
                HelpView()
                    .environment(\.locale, .init(identifier: id))
            }
        }
    }
}
