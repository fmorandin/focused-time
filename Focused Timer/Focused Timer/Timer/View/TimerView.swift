//
//  TimerView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 28/09/20.
//

import SwiftUI
import os

struct TimerView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TimerView.self)
    )

    // MARK: - Observed Objects

    @StateObject var timerViewModel: TimerViewModel

    // MARK: Initializer
    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {

        Self.logger.notice("🛠 Initializing Timer View.")

        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View
    var body: some View {
        ZStack {
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
                Self.logger.notice("‼️ App will be moved to background.")

                timerViewModel.moveAppToBackground()

                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification)) { _ in
                    timerViewModel.moveAppToForeground()
                    Self.logger.notice("‼️ App will be moved to foreground.")

                    if timerViewModel.shouldKeepScreenOn() {
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .updateTimerView), perform: { _ in
                    Self.logger.notice("🔄 Calling reset update timer.")
                    timerViewModel.resetUpdateTimer()
                })
                .onAppear {
                    Self.logger.notice("⏱ Timer View opened.")
                }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
