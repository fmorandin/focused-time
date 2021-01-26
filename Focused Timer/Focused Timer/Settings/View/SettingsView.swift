//
//  SettingsView.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 10/01/21.
//

import SwiftUI

struct SettingsView: View {

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Observed Objects
    @ObservedObject var settingsViewModel = SettingsViewModel()

    // MARK: - State
    @State var totalTime: String

    // MARK: - Body
    var body: some View {
        VStack {
            /// Top Section with a close button
            HStack {
                Spacer()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .padding(.trailing)
                        .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
                }
            }
            .padding(.top)
            .padding(.bottom, 50)

            /// The list that contains all the available settings to be defined in the app
            List {
                HStack {
                    Text("Focus Duration (in minutes)")
                    TextField("", text: $totalTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                }
            }
            .listStyle(InsetListStyle())

            Button(action: {
                settingsViewModel.saveTotalTime(time: $totalTime.wrappedValue)
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "checkmark")
                    .font(.system(size: 30))
                    .foregroundColor((colorScheme == .light ? Color.black : Color.white))
            }
            .padding(.bottom, 30)
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView(totalTime: "5")

            SettingsView(totalTime: "5").colorScheme(.dark)
        }
    }
}
