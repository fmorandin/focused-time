//
//  View+Extension.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 01/03/23.
//

import SwiftUI

extension View {

    func helpSectionTitle() -> some View {
        self
            .font(.system(.title3, design: .rounded).bold())
            .padding(.leading)
    }

    func helpSectionText() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(.callout, design: .rounded))
            .padding([.horizontal, .bottom])
    }

    // Warning box that currently is being used only in settings view if a timer is running
    func warningBox() -> some View {
        self
            .foregroundColor(.white)
            .font(.system(.caption, design: .rounded).bold())
            .padding(.all, 10)
            .background(.red)
    }

    func settingsTextField() -> some View {
        self
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(width: 50)
            .multilineTextAlignment(.center)
    }
}
