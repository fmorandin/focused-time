//
//  CloseButton.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 03/03/23.
//

import SwiftUI
import os

struct CloseButton: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HelpView.self)
    )

    // MARK: - Environment

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                Self.logger.notice("❌ Closing View.")
                presentationMode.wrappedValue.dismiss()
                HapticsConstants().impactMedium.impactOccurred()
            }, label: {
                Label(Translation.dismissModalButton, systemImage: ImageNames.closeModal)
                    .iconNoText()
                    .accessibilityIdentifier(Accessibility.Identifiers.btnCloseModal)
            })
        }
        .padding(.top, 30)
        .padding(.bottom, 10)
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton()
    }
}
