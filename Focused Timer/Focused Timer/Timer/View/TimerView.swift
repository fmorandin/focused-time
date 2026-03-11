//
//  TimerView.swift
//  Focused Timer
//

import SwiftUI
import os

struct TimerView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TimerView.self)
    )

    // MARK: - Environment

    @Environment(Router.self) private var router

    // MARK: - State

    @State var timerViewModel: TimerViewModel
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
        _timerViewModel = State(wrappedValue: viewModel)
        self.notificationCenter = notificationCenter
        self.setIdleTimerDisabled = setIdleTimerDisabled
    }

    // MARK: - View

    var body: some View {
        VStack {
            // Timer type pill — anchored at the top
            TimerTypePillView(viewModel: timerViewModel)
                .padding(.top, 32)

            Spacer()

            // Circle with countdown inside
            CircleView(viewModel: timerViewModel)

            Spacer()

            // Buttons that control the timer
            ButtonsView(viewModel: timerViewModel)

            Divider()

            // Flows counter
            FlowCounterView(viewModel: timerViewModel)
                .padding(.bottom, 16)
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
        .onChange(of: router.settingsDidChange) { _, didChange in
            if didChange {
                Self.logger.notice("🔄 Settings changed — resetting timer.")
                timerViewModel.resetUpdateTimer()
                router.settingsDidChange = false
            }
        }
        .onChange(of: router.selectedTab) { _, newTab in
            if newTab == .settings {
                router.settingsDisplaysWarning = timerViewModel.shouldDisplaySettingsAlert()
            }
        }
        .onAppear {
            Self.logger.notice("⏱ Timer View opened.")
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environment(Router())
    }
}
