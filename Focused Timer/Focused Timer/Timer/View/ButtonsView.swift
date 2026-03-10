//
//  ButtonsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI
import os

struct ButtonsView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ButtonsView.self)
    )

    // MARK: - Properties

    let timerViewModel: TimerViewModel

    // MARK: - Initializer

    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        Self.logger.notice("🛠 Initializing Buttons View.")
        self.timerViewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                if timerViewModel.timerState == .initial || timerViewModel.timerState == .paused {
                    Self.logger.notice("▶️ Play timer button pressed.")
                    timerViewModel.startTimer()
                } else {
                    Self.logger.notice("⏸ Pause timer button pressed.")
                    timerViewModel.pauseTimer()
                }
                HapticsConstants().impactHeavy.impactOccurred()
            }, label: {
                Label(timerViewModel.primaryButtonText, systemImage: timerViewModel.primaryButtonImageName)
                    .frame(maxWidth: .infinity, minHeight: 60)
            })
            .buttonStyle(.borderedProminent)
            .tint(timerViewModel.accentCircleColor)
            .controlSize(.large)
            .accessibilityIdentifier(Accessibility.Identifiers.btnStartPauseIdentifier)

            Button(action: {
                Self.logger.notice("🔄 Reset timer button pressed.")
                timerViewModel.resetUpdateTimer()
                HapticsConstants().impactHeavy.impactOccurred()
            }, label: {
                Label(LocalizedStringResource("resetTimer", table: "Localizable"), systemImage: ImageNames.reset)
                    .frame(maxWidth: .infinity, minHeight: 50)
            })
            .buttonStyle(.bordered)
            .tint(timerViewModel.accentCircleColor)
            .controlSize(.large)
            .accessibilityIdentifier(Accessibility.Identifiers.btnResetIdentifier)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
