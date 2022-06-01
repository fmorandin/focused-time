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

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme

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
                HStack(spacing: 10) {
                    Image(systemName:
                            timerViewModel.timerState == .running ?
                            ImageNames.pause :
                            ImageNames.play)
                        .foregroundColor(.white)

                    Text(timerViewModel.timerState == .running ?
                            Translation.pauseTimer :
                            Translation.playTimer)
                        .foregroundColor(.white)
                }
                .padding(.vertical)
                .frame(width: (UIScreen.main.bounds.width / 2) - 70, height: 60)
                .background(timerViewModel.accentCircleColor)
                .clipShape(Capsule())
                .shadow(radius: 6)
            })
            .accessibility(identifier: Accessibility.Identifiers.btnStartPauseIdentifier)

            Button(action: {
                Self.logger.notice("🔄 Reset timer button pressed.")
                timerViewModel.resetUpdateTimer()
                HapticsConstants().impactHeavy.impactOccurred()
            }, label: {
                HStack(spacing: 10) {
                    Image(systemName: ImageNames.reset)
                        .foregroundColor(.white)

                    Text(Translation.resetTimer)
                        .foregroundColor(.white)
                }
                .padding(.vertical)
                .frame(width: (UIScreen.main.bounds.width / 2) - 70, height: 60)
                .background(timerViewModel.accentCircleColor)
                .clipShape(Capsule())
                .shadow(radius: 6)
            })
            .accessibility(identifier: Accessibility.Identifiers.btnResetIdentifier)
        }
        .padding(.bottom, 20)
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
