//
//  ButtonsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI
import os

struct ButtonsView: View {

    // MARK: - Environment

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        HStack(spacing: 24) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    if timerViewModel.timerState == .initial || timerViewModel.timerState == .paused {
                        Self.logger.notice("▶️ Play timer button pressed.")
                        timerViewModel.startTimer()
                    } else {
                        Self.logger.notice("⏸ Pause timer button pressed.")
                        timerViewModel.pauseTimer()
                    }
                }
                HapticsConstants().impactHeavy.impactOccurred()
            }, label: {
                Image(systemName: timerViewModel.primaryButtonImageName)
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .replace)))
                    .foregroundStyle(timerViewModel.accentCircleColor)
                    .imageScale(.large)
                    .fontWeight(.semibold)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .contentShape(Capsule())
            })
            .accessibilityLabel(Text(timerViewModel.primaryButtonText))
            .frame(maxWidth: .infinity)
            .buttonStyle(ScaleButtonStyle(reduceMotion: reduceMotion))
            .background(timerViewModel.accentCircleColor.opacity(0.3), in: Capsule())
            .background(.ultraThinMaterial, in: Capsule())
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: timerViewModel.accentCircleColor)
            .accessibilityIdentifier(Accessibility.Identifiers.btnStartPauseIdentifier)

            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    Self.logger.notice("🔄 Reset timer button pressed.")
                    timerViewModel.resetUpdateTimer()
                }
                HapticsConstants().impactHeavy.impactOccurred()
            }, label: {
                Image(systemName: ImageNames.reset)
                    .foregroundStyle(timerViewModel.accentCircleColor)
                    .imageScale(.large)
                    .fontWeight(.semibold)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .contentShape(Capsule())
            })
            .accessibilityLabel(Text("resetTimer", tableName: "Localizable"))
            .frame(maxWidth: .infinity)
            .buttonStyle(ScaleButtonStyle(reduceMotion: reduceMotion))
            .background(.ultraThinMaterial, in: Capsule())
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: timerViewModel.accentCircleColor)
            .accessibilityIdentifier(Accessibility.Identifiers.btnResetIdentifier)
        }
        .padding(.horizontal, 48)
        .padding(.bottom, 24)
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.93 : 1.0)
            .animation(
                reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
