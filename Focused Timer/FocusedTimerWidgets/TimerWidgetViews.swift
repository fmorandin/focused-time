//
//  TimerWidgetViews.swift
//  FocusedTimerWidgets
//
//  SwiftUI views for each supported widget family.
//  systemSmall   — phase label + live countdown (no interactive button, too small)
//  systemMedium  — phase label + live countdown + Start/Pause button + cycle dots
//  accessoryCircular    — circular progress gauge + countdown (lock screen)
//  accessoryRectangular — phase label + countdown + Start/Pause button (lock screen)
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Entry View Dispatcher

struct TimerWidgetEntryView: View {

    let entry: TimerWidgetEntry

    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallTimerWidgetView(entry: entry)
        case .systemMedium:
            MediumTimerWidgetView(entry: entry)
        case .accessoryCircular:
            CircularTimerWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularTimerWidgetView(entry: entry)
        default:
            SmallTimerWidgetView(entry: entry)
        }
    }
}

// MARK: - systemSmall

struct SmallTimerWidgetView: View {

    let entry: TimerWidgetEntry

    var body: some View {
        VStack(spacing: 4) {
            Text(entry.timerState.timerType)
                .font(.caption)
                .foregroundStyle(.secondary)
            countdownView
                .font(.title2.monospacedDigit())
                .bold()
        }
        .padding()
    }

    @ViewBuilder
    private var countdownView: some View {
        if entry.timerState.state == "running", let endTime = entry.timerState.endTime {
            Text(timerInterval: entry.date...endTime, countsDown: true)
        } else {
            Text(formattedTime(entry.timerState.remainingSeconds))
        }
    }
}

// MARK: - systemMedium

struct MediumTimerWidgetView: View {

    let entry: TimerWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.timerState.timerType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                countdownView
                    .font(.title.monospacedDigit())
                    .bold()
                cycleDots
            }
            Spacer()
            toggleButton
        }
        .padding()
    }

    @ViewBuilder
    private var countdownView: some View {
        if entry.timerState.state == "running", let endTime = entry.timerState.endTime {
            Text(timerInterval: entry.date...endTime, countsDown: true)
        } else {
            Text(formattedTime(entry.timerState.remainingSeconds))
        }
    }

    private var cycleDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<max(1, entry.timerState.totalCycles), id: \.self) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(index < entry.timerState.completedCycles ? Color.accentColor : Color.secondary)
            }
        }
    }

    private var toggleButton: some View {
        Button(intent: WidgetTimerToggleIntent()) {
            Image(systemName: entry.timerState.state == "running" ? "pause.fill" : "play.fill")
                .font(.title2)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - accessoryCircular

struct CircularTimerWidgetView: View {

    let entry: TimerWidgetEntry

    private var progress: Double {
        guard entry.timerState.totalSeconds > 0 else { return 1 }
        if entry.timerState.state == "running", let endTime = entry.timerState.endTime {
            let remaining = max(0, endTime.timeIntervalSince(entry.date))
            return remaining / Double(entry.timerState.totalSeconds)
        }
        return Double(entry.timerState.remainingSeconds) / Double(entry.timerState.totalSeconds)
    }

    var body: some View {
        Gauge(value: progress) {
            EmptyView()
        } currentValueLabel: {
            countdownView
                .font(.caption2.monospacedDigit())
        }
        .gaugeStyle(.accessoryCircular)
    }

    @ViewBuilder
    private var countdownView: some View {
        if entry.timerState.state == "running", let endTime = entry.timerState.endTime {
            Text(timerInterval: entry.date...endTime, countsDown: true)
        } else {
            Text(formattedTime(entry.timerState.remainingSeconds))
        }
    }
}

// MARK: - accessoryRectangular

struct RectangularTimerWidgetView: View {

    let entry: TimerWidgetEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.timerState.timerType)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                countdownView
                    .font(.headline.monospacedDigit())
            }
            Spacer()
            Button(intent: WidgetTimerToggleIntent()) {
                Image(systemName: entry.timerState.state == "running" ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var countdownView: some View {
        if entry.timerState.state == "running", let endTime = entry.timerState.endTime {
            Text(timerInterval: entry.date...endTime, countsDown: true)
        } else {
            Text(formattedTime(entry.timerState.remainingSeconds))
        }
    }
}

// MARK: - Helpers

private func formattedTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remaining = seconds % 60
    return String(format: "%d:%02d", minutes, remaining)
}
