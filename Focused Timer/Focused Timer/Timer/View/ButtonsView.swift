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

    // MARK: - Observed Objects

    @StateObject var timerViewModel: TimerViewModel

    // MARK: - Initializer

    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        Self.logger.notice("🛠 Initializing Buttons View.")
        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View

    var body: some View {
        HStack(spacing: 70) {
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
                MainButtonLabel(
                    accentColor: timerViewModel.accentCircleColor,
                    imageName: timerViewModel.primaryButtonImageName,
                    text: timerViewModel.primaryButtonText
                )
            })
            .accessibilityIdentifier(Accessibility.Identifiers.btnStartPauseIdentifier)

            Button(action: {
                Self.logger.notice("🔄 Reset timer button pressed.")
                timerViewModel.resetUpdateTimer()
                HapticsConstants().impactHeavy.impactOccurred()
            }, label: {
                MainButtonLabel(
                    accentColor: timerViewModel.accentCircleColor,
                    imageName: ImageNames.reset,
                    text: LocalizedStringResource("resetTimer", table: "Localizable")
                )

            })
            .accessibilityIdentifier(Accessibility.Identifiers.btnResetIdentifier)
        }
        .padding(.bottom, 20)
        .padding(.horizontal, 24)
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
