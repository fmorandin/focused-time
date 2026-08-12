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
                Label(phaseTitle, systemImage: phaseSymbol)
                    .font(.headline)
                    .foregroundStyle(phaseColor)

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
                .tint(phaseColor)
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
        } else {
            ProgressView(value: displayedState.progress(at: referenceDate ?? displayedState.pauseDate ?? .now))
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

    private var phaseTitle: LocalizedStringKey {
        switch state.phase {
        case .focused:
            "focusName"
        case .shortBreak:
            "shortBreakName"
        case .longBreak:
            "longBreakName"
        }
    }

    private var statusTitle: LocalizedStringKey {
        switch displayedState.status {
        case .running:
            "liveActivityRunning"
        case .paused:
            "liveActivityPaused"
        case .completed:
            "liveActivityCompleted"
        }
    }

    private var phaseSymbol: String {
        switch state.phase {
        case .focused:
            "brain.head.profile"
        case .shortBreak:
            "cup.and.heat.waves.fill"
        case .longBreak:
            "leaf.fill"
        }
    }

    private var phaseColor: Color {
        switch state.phase {
        case .focused:
            .orange
        case .shortBreak:
            .blue
        case .longBreak:
            .green
        }
    }
}

struct LiveActivityCountdownText: View {
    let state: FocusedTimerActivityAttributes.ContentState
    var referenceDate: Date?

    var body: some View {
        if state.status == .completed {
            Text("00:00")
        } else if let referenceDate {
            Text(Self.formatted(state.remainingTime(at: referenceDate)))
        } else {
            Text(
                timerInterval: state.timerRange,
                pauseTime: state.status == .paused ? state.pauseDate : nil,
                countsDown: true,
                showsHours: true
            )
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

struct LiveActivityCompactLeadingView: View {
    let phase: TimerActivityPhase

    var body: some View {
        Image(systemName: phase == .focused ? "brain.head.profile" : "cup.and.heat.waves.fill")
            .foregroundStyle(phase == .focused ? .orange : phase == .shortBreak ? .blue : .green)
    }
}

struct LiveActivityCompactTrailingView: View {
    let state: FocusedTimerActivityAttributes.ContentState
    var referenceDate: Date?

    var body: some View {
        LiveActivityCountdownText(state: state, referenceDate: referenceDate)
            .font(.caption.monospacedDigit())
            .frame(minWidth: 42)
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
        FocusedTimerLiveActivityLockScreenView(
            state: state,
            isStale: isStale,
            referenceDate: referenceDate
        )
        .padding(.horizontal, -8)
    }
}
