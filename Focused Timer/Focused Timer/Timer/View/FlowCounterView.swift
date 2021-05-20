//
//  FlowCounterView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI

struct FlowCounterView: View {

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
        HStack {
            Spacer()

            Text(Translation.cycleCounter)
                .font(.title3)
                .fontWeight(.light)
                .accessibility(identifier: Accessibility.Identifiers.lblNumberOfCyclesCompleted)

            Spacer()

            Text("\(timerViewModel.numberOfCompletedCycles)/\(timerViewModel.totalNumberOfCycles)")
                .font(.title3)
                .fontWeight(.light)
                .accessibility(identifier: Accessibility.Identifiers.lblCycleCounter)
                .accessibility(value: Text(Translation.AccLabel.accLabelCompletedCycleCounter))

            Spacer()
        }
        .padding(.top, 20)
    }
}

struct FlowCounterView_Previews: PreviewProvider {
    static var previews: some View {
        FlowCounterView()
    }
}
