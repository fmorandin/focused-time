//
//  TimerWidgetViews.swift
//  FocusedTimerWidgets
//
//  SwiftUI views for each supported widget family.
//  systemSmall   — phase label + live countdown + cycle dots + Start/Pause button
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
                .font(.headline)
                .foregroundStyle(.secondary)
            countdownView
                .font(.title.monospacedDigit())
                .bold()
                .foregroundStyle(timerColor(for: entry.timerState.timerType))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            cycleDots
            Spacer().frame(height: 6)
            toggleButton
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

    private var cycleDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<max(1, entry.timerState.totalCycles), id: \.self) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(
                        index < entry.timerState.completedCycles
                            ? timerColor(for: entry.timerState.timerType)
                            : Color.secondary
                    )
            }
        }
    }

    private var toggleButton: some View {
        Button(intent: WidgetTimerToggleIntent()) {
            Image(systemName: entry.timerState.state == "running" ? "pause.fill" : "play.fill")
                .font(.title)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helpers

private func timerColor(for timerType: String) -> Color {
    switch timerType {
    case "Short Break": return Color("ShortBreakColor")
    case "Long Break": return Color("LongBreakColor")
    default: return Color("AccentColor")
    }
}

private func formattedTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remaining = seconds % 60
    return String(format: "%d:%02d", minutes, remaining)
}
