//
//  MainButtonLabel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 03/03/23.
//

import SwiftUI

struct MainButtonLabel: View {

    var accentColor: Color
    var imageName: String
    var text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: imageName)

            Text(text)
                .font(.system(.callout, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.vertical)
        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
        .background(accentColor)
        .clipShape(Capsule())
        .shadow(radius: 6)
    }
}

struct MainButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
         MainButtonLabel(
            accentColor: Color.accentColor,
            imageName: ImageNames.play,
            text: Translation.playTimer
         )
    }
}
