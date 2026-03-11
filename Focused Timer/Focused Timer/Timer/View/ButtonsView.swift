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

    // MARK: - State

    @State private var primaryButtonPressed = false
    @State private var resetButtonPressed = false

    // MARK: - Initializer

    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        Self.logger.notice("🛠 Initializing Buttons View.")
        self.timerViewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        HStack(spacing: 12) {
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
                Label(timerViewModel.primaryButtonText, systemImage: timerViewModel.primaryButtonImageName)
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .replace)))
                    .foregroundStyle(timerViewModel.accentCircleColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            })
            .frame(maxWidth: .infinity)
            .buttonStyle(.plain)
            .background(timerViewModel.accentCircleColor.opacity(0.3), in: Capsule())
            .background(.ultraThinMaterial, in: Capsule())
            .animation(.easeInOut(duration: 0.35), value: timerViewModel.accentCircleColor)
            .scaleEffect(primaryButtonPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: primaryButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in primaryButtonPressed = true }
                    .onEnded { _ in primaryButtonPressed = false }
            )
            .accessibilityIdentifier(Accessibility.Identifiers.btnStartPauseIdentifier)

            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    Self.logger.notice("🔄 Reset timer button pressed.")
                    timerViewModel.resetUpdateTimer()
                }
                HapticsConstants().impactHeavy.impactOccurred()
            }, label: {
                Label(LocalizedStringResource("resetTimer", table: "Localizable"), systemImage: ImageNames.reset)
                    .foregroundStyle(timerViewModel.accentCircleColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            })
            .frame(maxWidth: .infinity)
            .buttonStyle(.plain)
            .background(.ultraThinMaterial, in: Capsule())
            .animation(.easeInOut(duration: 0.35), value: timerViewModel.accentCircleColor)
            .scaleEffect(resetButtonPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: resetButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in resetButtonPressed = true }
                    .onEnded { _ in resetButtonPressed = false }
            )
            .accessibilityIdentifier(Accessibility.Identifiers.btnResetIdentifier)
        }
        .font(.title3)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
