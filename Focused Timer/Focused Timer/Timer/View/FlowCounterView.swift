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
        HStack {
            Spacer()

            Text("cycleCounter")
                .accessibilityIdentifier(Accessibility.Identifiers.lblNumberOfCyclesCompleted)

            Spacer()

            Text("\(timerViewModel.numberOfCompletedCycles)/\(timerViewModel.totalNumberOfCycles)")
                .accessibilityIdentifier(Accessibility.Identifiers.lblCycleCounter)
                .accessibilityValue(Text("accLabelCompletedCycleCounter"))

            Spacer()
        }
        .font(.system(.title3, design: .rounded).weight(.light))
        .padding(.top, 20)
    }
}

struct FlowCounterView_Previews: PreviewProvider {
    static var previews: some View {
        FlowCounterView()
    }
}
