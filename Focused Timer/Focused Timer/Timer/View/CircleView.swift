//
//  CircleView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI

struct CircleView: View {

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Observed Objects
    @StateObject var timerViewModel: TimerViewModel

    // MARK: - Initializer
    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke((colorScheme == .light ? Color.black : Color.white).opacity(0.09),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: 300, height: 300)

            Circle()
                .trim(from: 0, to: timerViewModel.timerTo)
                .stroke(timerViewModel.accentCircleColor,
                        style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .frame(width: 300, height: 300)
                .rotationEffect(.init(degrees: -90))
                .shadow(radius: 4)
                .accessibility(identifier:
                                timerViewModel.timerType == .focused ?
                                Identifiers.circleFocused :
                                Identifiers.circleRest)

            VStack {
                Text(timerViewModel.countTime)
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .accessibility(identifier: Identifiers.lblCounter)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
