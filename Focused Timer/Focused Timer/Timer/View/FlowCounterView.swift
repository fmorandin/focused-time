//
//  FlowCounterView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI
import os

struct FlowCounterView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FlowCounterView.self)
    )

    // MARK: - Properties

    let timerViewModel: TimerViewModel

    // MARK: - Initializer

    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        Self.logger.notice("🛠 Initializing Flow Counter View.")
        self.timerViewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "circle.dotted")
                    .font(.system(.caption, design: .rounded))
                    .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesCompleted)

                Text("\(timerViewModel.numberOfCompletedCycles)/\(timerViewModel.totalNumberOfCycles)")
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .accessibilityIdentifier(Accessibility.Identifiers.lblCycleCounter)
                    .accessibilityValue(Text("accLabelCompletedCycleCounter"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .glassEffect(in: Capsule())
        }
        .padding(.top, 20)
    }
}

struct FlowCounterView_Previews: PreviewProvider {
    static var previews: some View {
        FlowCounterView()
    }
}
