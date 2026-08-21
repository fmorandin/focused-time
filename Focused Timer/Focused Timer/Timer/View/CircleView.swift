//
//  CircleView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI
import os

struct CircleView: View {

    // MARK: - Environment

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .largeTitle) private var countdownFontSize = 56

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CircleView.self)
    )

    // MARK: - Properties

    let timerViewModel: TimerViewModel

    // MARK: - Initializer

    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        Self.logger.notice("🛠 Initializing Circle View.")
        self.timerViewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(320, max(0, geometry.size.width - 48))

            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        Color.timerStrokeColor.opacity(0.10),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .shadow(color: .white.opacity(0.12), radius: 4, x: 0, y: -2)
                    .accessibilityHidden(true)

                Circle()
                    .trim(from: 0, to: timerViewModel.timerTo)
                    .stroke(
                        timerViewModel.accentCircleColor,
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                    .rotationEffect(.init(degrees: -90))
                    .shadow(radius: 4)
                    .animation(reduceMotion ? nil : .linear(duration: 1), value: timerViewModel.timerTo)
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 0.5),
                        value: timerViewModel.accentCircleColor
                    )
                    .accessibilityHidden(true)

                Text(timerViewModel.countTime)
                    .font(.system(size: min(countdownFontSize, 72), weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(width: max(0, diameter - 72))
                    .accessibilityIdentifier(Accessibility.Identifiers.lblCounter)
                    .accessibilityLabel(Text("accessibilityTimeRemaining"))
                    .accessibilityValue(Text(verbatim: timerViewModel.countTime))
                    .contentTransition(.numericText(countsDown: true))
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: timerViewModel.countTime)
            }
            .frame(width: diameter, height: diameter)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 368)
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
