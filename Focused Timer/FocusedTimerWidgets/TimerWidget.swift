//
//  TimerWidget.swift
//  FocusedTimerWidgets
//
//  Declares the widget configuration and supported families.
//

import SwiftUI
import WidgetKit

struct TimerWidget: Widget {

    let kind: String = "TimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerTimelineProvider()) { entry in
            TimerWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Focused Timer")
        .description("Track your focus sessions from your home screen.")
        .supportedFamilies([.systemSmall])
    }
}
