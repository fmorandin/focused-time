//
//  TimerView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 28/09/20.
//

import SwiftUI

struct TimerView: View {

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Oberved Objects
    @StateObject var timerViewModel: TimerViewModel

    // MARK: Initializer
    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View
    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack {

                Spacer()

                // Top section with the config button
                TopMenuView(viewModel: timerViewModel)

                Spacer()

                // Main circles
                CircleView(viewModel: timerViewModel)

                Spacer()

                // Buttons that controls the timer
                ButtonsView(viewModel: timerViewModel)

                Divider()

                // Flows counter
                FlowCounterView(viewModel: timerViewModel)

                Spacer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.didEnterBackgroundNotification)) { _ in
            timerViewModel.moveAppToBackground()
        }
        .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification)) { _ in
            timerViewModel.moveAppToForeground()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
