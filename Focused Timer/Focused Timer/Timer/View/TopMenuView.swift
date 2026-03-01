//
//  TopMenuView.swift
//  Focused Timer
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

    @EnvironmentObject private var router: Router

    // MARK: - Observed Objects

    @ObservedObject var timerViewModel: TimerViewModel

    // MARK: - Initializer

    init(viewModel: TimerViewModel) {
        Self.logger.notice("🛠 Initializing Top Menu View.")
        self.timerViewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        HStack {
            Button(action: {
                Self.logger.notice("🆘 Opening Help View.")
                router.openHelp()
                HapticsConstants().impactLight.impactOccurred()
            }, label: {
                Label("timerViewOpenHelpModalButton", systemImage: ImageNames.showHelp)
                    .iconNoText()
            })
            .sheet(isPresented: $router.isShowingHelp, content: {
                HelpView()
            })
            .accessibilityIdentifier(Accessibility.Identifiers.btnShowHelp)

            Spacer()

            Button(action: {
                Self.logger.notice("⚙️ Opening Settings View.")
                router.openSettings(isTimerActive: timerViewModel.shouldDisplaySettingsAlert())
                HapticsConstants().impactLight.impactOccurred()
            }, label: {
                Label("timerViewOpenSettingsModalButton", systemImage: ImageNames.showSettings)
                    .iconNoText()
            })
            .sheet(isPresented: $router.isShowingSettings) {
                SettingsView(displayWarning: router.settingsDisplaysWarning)
            }
            .accessibilityIdentifier(Accessibility.Identifiers.btnShowSettings)
        }
        .padding(.leading, 40)
        .padding(.trailing, 20)
    }
}

struct TopMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TopMenuView(viewModel: TimerViewModel(timerModel: TimerModel()))
            .environmentObject(Router())
    }
}
