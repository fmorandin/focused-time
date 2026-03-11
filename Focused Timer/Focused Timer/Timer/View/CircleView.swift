//
//  CircleView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI
import os

struct CircleView: View {

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
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    Color.timerStrokeColor.opacity(0.10),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                .shadow(color: .white.opacity(0.12), radius: 4, x: 0, y: -2)
                .frame(width: 320, height: 320)

            Circle()
                .trim(from: 0, to: timerViewModel.timerTo)
                .stroke(
                    timerViewModel.accentCircleColor,
                    style: StrokeStyle(lineWidth: 30, lineCap: .round)
                )
                .frame(width: 320, height: 320)
                .rotationEffect(.init(degrees: -90))
                .shadow(radius: 4)
                .animation(.linear(duration: 1), value: timerViewModel.timerTo)
                .animation(.easeInOut(duration: 0.5), value: timerViewModel.accentCircleColor)
                .accessibility(identifier:
                                timerViewModel.timerType == .focused ?
                               Accessibility.Identifiers.circleFocused :
                                Accessibility.Identifiers.circleBreak
                )

            VStack {
                Text(TimerType.getCorrectTranslation(timerViewModel.timerType)())
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.light)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblTimerType)
                    .accessibility(value: Text("accLabelTimerTypeName"))
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.35), value: timerViewModel.timerType)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .glassEffect(in: Capsule())

                Text(timerViewModel.countTime)
                    .font(.system(size: 60, design: .rounded))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblCounter)
                    .accessibility(value: Text("accLabelCounterTypeName"))
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.easeInOut(duration: 0.25), value: timerViewModel.countTime)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .glassEffect()
        }
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
