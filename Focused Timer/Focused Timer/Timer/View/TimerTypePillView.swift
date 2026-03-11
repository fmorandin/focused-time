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
            .accessibility(value: Text("accLabelTimerTypeName"))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .glassEffect(in: Capsule())
            .id(timerViewModel.timerType)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.75).combined(with: .opacity),
                removal: .scale(scale: 0.75).combined(with: .opacity)
                    .animation(.easeInOut(duration: 0.55))
            ))
            .animation(.spring(response: 0.55, dampingFraction: 0.45), value: timerViewModel.timerType)
    }
}

struct TimerTypePillView_Previews: PreviewProvider {
    static var previews: some View {
        TimerTypePillView()
    }
}
