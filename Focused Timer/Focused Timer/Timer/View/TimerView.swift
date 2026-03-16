//
//  TimerView.swift
//  Focused Timer
//

import StoreKit
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
        .onChange(of: timerViewModel.shouldRequestReview) { _, shouldRequest in
            if shouldRequest {
                Self.logger.notice("⭐️ onChange fired — requesting review.")
                presentReviewRequest()
                timerViewModel.shouldRequestReview = false
            }
        }
        .onReceive(notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // The timer may have completed while the app was in the background,
            // setting shouldRequestReview during willEnterForeground (when the scene
            // is still inactive). Re-check here, when the scene is guaranteed active.
            if timerViewModel.shouldRequestReview {
                Self.logger.notice("⭐️ didBecomeActive fired — requesting review.")
                presentReviewRequest()
                timerViewModel.shouldRequestReview = false
            }
        }
        .onAppear {
            Self.logger.notice("⏱ Timer View opened.")
        }
    }

    // MARK: - Private

    private func presentReviewRequest() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            Self.logger.notice("⭐️ Review skipped — no active window scene found.")
            return
        }
        SKStoreReviewController.requestReview(in: scene)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environment(Router())
    }
}
