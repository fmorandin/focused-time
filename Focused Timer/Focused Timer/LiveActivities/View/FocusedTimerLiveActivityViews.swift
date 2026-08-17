//
//  FocusedTimerLiveActivityViews.swift
//  Focused Timer
//

import SwiftUI

struct FocusedTimerLiveActivityLockScreenView: View {
    let state: FocusedTimerActivityAttributes.ContentState
    let isStale: Bool
    var referenceDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(state.phase.title, systemImage: state.phase.symbol)
                    .font(.headline)
                    .foregroundStyle(state.phase.color)

                Spacer()

                cyclesLabel
            }

            HStack(alignment: .firstTextBaseline) {
                countdown
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                Spacer()

                Text(statusTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            progress
                .tint(state.phase.color)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }

    private var countdown: some View {
        LiveActivityCountdownText(state: displayedState, referenceDate: referenceDate)
    }

    @ViewBuilder
    private var progress: some View {
        if displayedState.status == .running, referenceDate == nil {
            ProgressView(timerInterval: displayedState.timerRange, countsDown: true)
                .labelsHidden()
        } else {
            ProgressView(value: displayedState.progress(at: referenceDate ?? displayedState.pauseDate ?? .now))
                .labelsHidden()
        }
    }

    private var displayedState: FocusedTimerActivityAttributes.ContentState {
        if isStale, state.status == .running {
            return state.completed(at: state.timerEndDate)
        }
        return state
    }

    private var cyclesLabel: some View {
        Text("\(state.completedCycles)/\(state.totalCycles)")
            .font(.subheadline.monospacedDigit())
            .foregroundStyle(.secondary)
    }

    private var statusTitle: LocalizedStringKey {
        displayedState.status.title
    }
}

struct LiveActivityCountdownText: View {
    let state: FocusedTimerActivityAttributes.ContentState
    var referenceDate: Date?

    var body: some View {
        switch Self.presentation(for: state, referenceDate: referenceDate) {
        case .staticText(let value):
            Text(value)
        case .timerRange(let range):
            Text(
                timerInterval: range,
                countsDown: true,
                showsHours: true
            )
        }
    }

    static func presentation(
        for state: FocusedTimerActivityAttributes.ContentState,
        referenceDate: Date?
    ) -> LiveActivityCountdownPresentation {
        switch state.status {
        case .completed:
            .staticText("00:00")
        case .paused:
            .staticText(formatted(state.remainingTime(at: state.pauseDate ?? referenceDate ?? .now)))
        case .running:
            if let referenceDate {
                .staticText(formatted(state.remainingTime(at: referenceDate)))
            } else {
                .timerRange(state.timerRange)
            }
        }
    }

    static func formatted(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded(.down)))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%02d:%02d", minutes, seconds)
    }
}

enum LiveActivityCountdownPresentation: Equatable {
    case staticText(String)
    case timerRange(ClosedRange<Date>)
}

struct LiveActivityCompactLeadingView: View {
    let phase: TimerActivityPhase

    var body: some View {
        Image(systemName: phase.symbol)
            .foregroundStyle(phase.color)
    }
}

struct LiveActivityCompactTrailingView: View {
    let state: FocusedTimerActivityAttributes.ContentState
    var referenceDate: Date?

    var body: some View {
        LiveActivityCountdownText(state: state, referenceDate: referenceDate)
            .font(.caption.monospacedDigit())
            .frame(minWidth: 42)
            .padding(.trailing, 6)
    }
}

struct FocusedTimerLiveActivityMinimalView: View {
    let state: FocusedTimerActivityAttributes.ContentState
    var referenceDate: Date?

    var body: some View {
        LiveActivityCountdownText(state: state, referenceDate: referenceDate)
            .font(.caption2.monospacedDigit())
            .minimumScaleFactor(0.7)
    }
}

struct LiveActivityExpandedBottomView: View {
    let state: FocusedTimerActivityAttributes.ContentState
    let isStale: Bool
    var referenceDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                LiveActivityCountdownText(state: displayedState, referenceDate: referenceDate)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                Spacer()

                Text(displayedState.status.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            progress
                .tint(state.phase.color)
        }
    }

    @ViewBuilder
    private var progress: some View {
        if displayedState.status == .running, referenceDate == nil {
            ProgressView(timerInterval: displayedState.timerRange, countsDown: true)
                .labelsHidden()
        } else {
            ProgressView(value: displayedState.progress(at: referenceDate ?? displayedState.pauseDate ?? .now))
                .labelsHidden()
        }
    }

    private var displayedState: FocusedTimerActivityAttributes.ContentState {
        if isStale, state.status == .running {
            return state.completed(at: state.timerEndDate)
        }
        return state
    }
}

struct LiveActivityExpandedLeadingView: View {
    let phase: TimerActivityPhase

    var body: some View {
        Label(phase.title, systemImage: phase.symbol)
            .font(.headline)
            .foregroundStyle(phase.color)
    }
}

struct LiveActivityExpandedTrailingView: View {
    let completedCycles: Int
    let totalCycles: Int

    var body: some View {
        Text("\(completedCycles)/\(totalCycles)")
            .font(.subheadline.monospacedDigit())
            .foregroundStyle(.secondary)
    }
}

private extension TimerActivityPhase {
    var title: LocalizedStringKey {
        switch self {
        case .focused:
            "focusName"
        case .shortBreak:
            "shortBreakName"
        case .longBreak:
            "longBreakName"
        }
    }

    var symbol: String {
        switch self {
        case .focused:
            "brain.head.profile"
        case .shortBreak:
            "cup.and.heat.waves.fill"
        case .longBreak:
            "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .focused:
            .orange
        case .shortBreak:
            .blue
        case .longBreak:
            .green
        }
    }
}

private extension TimerActivityStatus {
    var title: LocalizedStringKey {
        switch self {
        case .running:
            "liveActivityRunning"
        case .paused:
            "liveActivityPaused"
        case .completed:
            "liveActivityCompleted"
        }
    }
}
