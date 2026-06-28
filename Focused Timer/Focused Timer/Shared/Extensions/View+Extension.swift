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
            .padding(.top, 8)
    }

    func helpSectionText() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(.callout, design: .rounded))
            .padding()
            .listRowInsets(EdgeInsets())
    }

    // Warning box displayed in settings when a timer is active
    func warningBox() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(.callout, design: .rounded))
            self
                .font(.system(.footnote, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.red.opacity(0.85), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    func settingsTextField() -> some View {
        self
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(width: 50)
            .multilineTextAlignment(.center)
    }
}
