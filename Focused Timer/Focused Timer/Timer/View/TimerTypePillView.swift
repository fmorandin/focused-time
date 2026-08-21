//
//  TimerTypePillView.swift
//  Focused Timer
//
//  Displays the current timer phase (Focus / Short Break / Long Break)
//  as an animated glass capsule pill. Phase changes trigger a spring
//  pop-in transition and a slower ease-out for the outgoing pill.
//

import SwiftUI
import os

struct TimerTypePillView: View {

    // MARK: - Environment

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TimerTypePillView.self)
    )

    // MARK: - Properties

    let timerViewModel: TimerViewModel

    // MARK: - Initializer

    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        Self.logger.notice("🛠 Initializing Timer Type Pill View.")
        self.timerViewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        Text(TimerType.getCorrectTranslation(timerViewModel.timerType)())
            .font(.system(.title, design: .rounded))
            .fontWeight(.light)
            .accessibilityIdentifier(Accessibility.Identifiers.lblTimerType)
            .accessibilityLabel(Text("accessibilityCurrentTimer"))
            .accessibilityValue(Text(TimerType.getCorrectTranslation(timerViewModel.timerType)()))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .glassEffect(in: Capsule())
            .id(timerViewModel.timerType)
            .transition(reduceMotion ? .identity : timerTypeTransition)
            .animation(
                reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.45),
                value: timerViewModel.timerType
            )
    }

    private var timerTypeTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.75).combined(with: .opacity),
            removal: .scale(scale: 0.75).combined(with: .opacity)
                .animation(.easeInOut(duration: 0.55))
        )
    }
}

struct TimerTypePillView_Previews: PreviewProvider {
    static var previews: some View {
        TimerTypePillView()
    }
}
