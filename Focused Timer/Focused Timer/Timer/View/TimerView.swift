//
//  TimerView.swift
//  Focused Timer
//

import StoreKit
import SwiftUI
import os

struct TimerView: View {

    // MARK: - Environment

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        viewModel: TimerViewModel = TimerService.shared.timerViewModel,
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
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                ScrollView {
                    timerContent(spacedForAccessibility: true)
                }
            } else {
                timerContent(spacedForAccessibility: false)
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
            synchronizeIdleTimer()
        }
        .onChange(of: router.settingsDidChange) { _, didChange in
            if didChange {
                Self.logger.notice("🔄 Settings changed — resetting timer.")
                timerViewModel.resetUpdateTimer()
                synchronizeIdleTimer()
                router.settingsDidChange = false
            }
        }
        .onChange(of: router.selectedTab) { _, newTab in
            synchronizeIdleTimer()
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
            synchronizeIdleTimer()
        }
    }

    // MARK: - Private Views

    private func timerContent(spacedForAccessibility: Bool) -> some View {
        VStack(spacing: spacedForAccessibility ? 24 : 0) {
            TimerTypePillView(viewModel: timerViewModel)
                .padding(.top, spacedForAccessibility ? 20 : 32)

            if !spacedForAccessibility {
                Spacer()
            }

            CircleView(viewModel: timerViewModel)

            if !spacedForAccessibility {
                Spacer()
            }

            ButtonsView(viewModel: timerViewModel)

            Divider()

            FlowCounterView(viewModel: timerViewModel)
                .padding(.bottom, 16)
        }
    }

    // MARK: - Private

    private func presentReviewRequest() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            Self.logger.notice("⭐️ Review skipped — no active window scene found.")
            return
        }
        AppStore.requestReview(in: scene)
    }

    private func synchronizeIdleTimer() {
        timerViewModel.synchronizeIdleTimer(
            isTimerVisible: router.selectedTab == .timer,
            using: setIdleTimerDisabled
        )
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environment(Router())
    }
}
