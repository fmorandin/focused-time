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
    private let notificationCenter: NotificationCenter
    private let setIdleTimerDisabled: (Bool) -> Void

    // MARK: Initializer
    init(
        viewModel: TimerViewModel = .init(timerModel: TimerModel()),
        notificationCenter: NotificationCenter = .default,
        setIdleTimerDisabled: @escaping (Bool) -> Void = { isDisabled in
            UIApplication.shared.isIdleTimerDisabled = isDisabled
        }
    ) {
        Self.logger.notice("🛠 Initializing Timer View.")
        _timerViewModel = StateObject(wrappedValue: viewModel)
        self.notificationCenter = notificationCenter
        self.setIdleTimerDisabled = setIdleTimerDisabled
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
        .onReceive(notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            Self.logger.notice("‼️ App will be moved to background.")
            timerViewModel.moveAppToBackground()
            setIdleTimerDisabled(false)
        }
        .onReceive(notificationCenter.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            timerViewModel.moveAppToForeground()
            Self.logger.notice("‼️ App will be moved to foreground.")
            if timerViewModel.shouldKeepScreenOn() {
                setIdleTimerDisabled(true)
            }
        }
        .onReceive(notificationCenter.publisher(for: .updateTimerView)) { _ in
            Self.logger.notice("🔄 Calling reset update timer.")
            timerViewModel.resetUpdateTimer()
        }
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
