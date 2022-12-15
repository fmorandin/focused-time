//
//  TopMenuView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI
import os

struct TopMenuView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TopMenuView.self)
    )

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme

    // MARK: - States

    @State private var showingConfig = false
    @State private var showingHelp = false

    // MARK: - Observed Objects

    @StateObject var timerViewModel: TimerViewModel

    // MARK: - Initializer

    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {

        Self.logger.notice("🛠 Initializing Top Menu View.")

        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View
    var body: some View {
        HStack {
            Button(action: {
                Self.logger.notice("🆘 Opening Help View.")
                showingHelp.toggle()
                HapticsConstants().impactLight.impactOccurred()
            }, label: {
                Label(Translation.timerViewOpenHelpModalButton, systemImage: ImageNames.showHelp)
                    .labelStyle(IconOnlyLabelStyle())
                    .font(.system(size: 25))
                    .padding(.trailing)
                    .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)

            })
            .sheet(isPresented: $showingHelp, content: {
                HelpView()
            })
            .accessibility(identifier: Accessibility.Identifiers.btnShowHelp)

            Spacer()

            Button(action: {
                Self.logger.notice("⚙️ Opening Settings View.")
                showingConfig.toggle()
                HapticsConstants().impactLight.impactOccurred()
            }, label: {
                Label(Translation.timerViewOpenSettingsModalButton, systemImage: ImageNames.showSettings)
                    .labelStyle(IconOnlyLabelStyle())
                    .font(.system(size: 25))
                    .padding(.trailing)
                    .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
            })
            .sheet(isPresented: $showingConfig) {
                SettingsView(displayWarning: timerViewModel.shouldDisplaySettingsAlert())
            }
            .accessibility(identifier: Accessibility.Identifiers.btnShowSettings)
        }
        .padding(.leading, 40)
        .padding(.trailing, 20)
    }
}

struct TopMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TopMenuView()
    }
}
