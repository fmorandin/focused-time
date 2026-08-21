//
//  FlowCounterView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI
import os

struct FlowCounterView: View {

    // MARK: - Environment

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        VStack(spacing: 8) {
            Text("cyclesLabel")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                ForEach(0..<timerViewModel.totalNumberOfCycles, id: \.self) { index in
                    self.cycleDot(at: index)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(Accessibility.Identifiers.lblCycleCounter)
            .accessibilityLabel(Text("accessibilityCyclesCompleted"))
            .accessibilityValue(
                Text(
                    String(
                        format: String(localized: "accessibilityCyclesCompletedValue"),
                        timerViewModel.numberOfCompletedCycles,
                        timerViewModel.totalNumberOfCycles
                    )
                )
            )
            .accessibilityAddTraits(.isStaticText)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .glassEffect(in: Capsule())
        .padding(.top, 20)
    }

    // MARK: - Private View Builders

    @ViewBuilder
    private func cycleDot(at index: Int) -> some View {
        let isCompleted = index < timerViewModel.numberOfCompletedCycles
        Circle()
            .fill(isCompleted ? Color.primary : Color.clear)
            .overlay(
                Circle()
                    .strokeBorder(
                        isCompleted ? Color.primary : Color.primary.opacity(0.4),
                        lineWidth: 1.5
                    )
            )
            .frame(width: 12, height: 12)
            .animation(
                reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.55)
                    .delay(Double(index) * 0.04),
                value: timerViewModel.numberOfCompletedCycles
            )
            .accessibilityHidden(true)
    }
}

struct FlowCounterView_Previews: PreviewProvider {
    static var previews: some View {
        FlowCounterView()
    }
}
