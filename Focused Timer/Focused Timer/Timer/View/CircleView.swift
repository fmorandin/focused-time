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
                    Color.timerStrokeColor.opacity(0.09),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .frame(width: 300, height: 300)

            Circle()
                .trim(from: 0, to: timerViewModel.timerTo)
                .stroke(
                    timerViewModel.accentCircleColor,
                    style: StrokeStyle(lineWidth: 25, lineCap: .round)
                )
                .frame(width: 300, height: 300)
                .rotationEffect(.init(degrees: -90))
                .shadow(radius: 4)
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

                Text(timerViewModel.countTime)
                    .font(.system(size: 60, design: .rounded))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(Accessibility.Identifiers.lblCounter)
                    .accessibility(value: Text("accLabelCounterTypeName"))
            }
        }
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
