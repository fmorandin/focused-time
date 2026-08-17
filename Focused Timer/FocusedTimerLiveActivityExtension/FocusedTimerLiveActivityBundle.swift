//
//  FocusedTimerLiveActivityBundle.swift
//  FocusedTimerLiveActivityExtension
//

import ActivityKit
import SwiftUI
import WidgetKit

@main
struct FocusedTimerLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        FocusedTimerLiveActivityWidget()
    }
}

struct FocusedTimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusedTimerActivityAttributes.self) { context in
            FocusedTimerLiveActivityLockScreenView(
                state: context.state,
                isStale: context.isStale
            )
            .activityBackgroundTint(.black.opacity(0.08))
            .activitySystemActionForegroundColor(.primary)
            .widgetURL(URL(string: "focusedtimer://timer"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    LiveActivityExpandedLeadingView(phase: context.state.phase)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    LiveActivityExpandedTrailingView(
                        completedCycles: context.state.completedCycles,
                        totalCycles: context.state.totalCycles
                    )
                }
                DynamicIslandExpandedRegion(.bottom) {
                    LiveActivityExpandedBottomView(
                        state: context.state,
                        isStale: context.isStale
                    )
                }
            } compactLeading: {
                LiveActivityCompactLeadingView(phase: context.state.phase)
            } compactTrailing: {
                LiveActivityCompactTrailingView(state: context.state)
            } minimal: {
                FocusedTimerLiveActivityMinimalView(state: context.state)
            }
            .widgetURL(URL(string: "focusedtimer://timer"))
            .keylineTint(.orange)
        }
    }
}
