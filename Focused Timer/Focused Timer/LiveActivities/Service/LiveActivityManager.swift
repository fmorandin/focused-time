//
//  LiveActivityManager.swift
//  Focused Timer
//

import ActivityKit
import Foundation
import os

enum LiveActivityEvent: Equatable, Sendable {
    case reconcile(TimerActivitySnapshot?)
    case started(TimerActivitySnapshot)
    case paused(TimerActivitySnapshot)
    case phaseCompleted(completionDate: Date, nextSnapshot: TimerActivitySnapshot?)
    case reset
    case preferenceChanged(Bool)
}

protocol LiveActivityManaging: Sendable {
    func handle(_ event: LiveActivityEvent)
}

struct LiveActivityRecord: Equatable, Sendable {
    let identifier: String
    let state: FocusedTimerActivityAttributes.ContentState
}

protocol LiveActivityClient: Sendable {
    var areActivitiesEnabled: Bool { get }
    func activeActivities() -> [LiveActivityRecord]
    func request(
        attributes: FocusedTimerActivityAttributes,
        content: ActivityContent<FocusedTimerActivityAttributes.ContentState>
    ) throws -> String
    func update(
        identifier: String,
        content: ActivityContent<FocusedTimerActivityAttributes.ContentState>
    ) async
    func end(
        identifier: String,
        content: ActivityContent<FocusedTimerActivityAttributes.ContentState>?,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async
}

struct ActivityKitLiveActivityClient: LiveActivityClient {
    var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func activeActivities() -> [LiveActivityRecord] {
        Activity<FocusedTimerActivityAttributes>.activities.map {
            LiveActivityRecord(identifier: $0.id, state: $0.content.state)
        }
    }

    func request(
        attributes: FocusedTimerActivityAttributes,
        content: ActivityContent<FocusedTimerActivityAttributes.ContentState>
    ) throws -> String {
        try Activity.request(attributes: attributes, content: content, pushType: nil).id
    }

    func update(
        identifier: String,
        content: ActivityContent<FocusedTimerActivityAttributes.ContentState>
    ) async {
        guard let activity = Activity<FocusedTimerActivityAttributes>.activities.first(
            where: { $0.id == identifier }
        ) else { return }
        await activity.update(content)
    }

    func end(
        identifier: String,
        content: ActivityContent<FocusedTimerActivityAttributes.ContentState>?,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async {
        guard let activity = Activity<FocusedTimerActivityAttributes>.activities.first(
            where: { $0.id == identifier }
        ) else { return }
        await activity.end(content, dismissalPolicy: dismissalPolicy)
    }
}

actor LiveActivityCoordinator {

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "FocusedTimer",
        category: String(describing: LiveActivityCoordinator.self)
    )

    private let client: any LiveActivityClient
    private let repository: any StorageRepository
    private let nowProvider: @Sendable () -> Date
    private var latestSnapshot: TimerActivitySnapshot?
    private var pendingEvents: [Int: LiveActivityEvent] = [:]
    private var nextSequence = 0
    private var isDraining = false

    init(
        client: any LiveActivityClient = ActivityKitLiveActivityClient(),
        repository: any StorageRepository = UserDefaultsRepository(),
        nowProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.client = client
        self.repository = repository
        self.nowProvider = nowProvider
    }

    func enqueue(_ event: LiveActivityEvent, sequence: Int) async {
        pendingEvents[sequence] = event
        guard !isDraining else { return }
        isDraining = true

        while let nextEvent = pendingEvents.removeValue(forKey: nextSequence) {
            await handle(nextEvent)
            nextSequence += 1
        }

        isDraining = false
    }

    func handle(_ event: LiveActivityEvent) async {
        switch event {
        case .reconcile(let snapshot):
            latestSnapshot = snapshot
            await reconcile(snapshot)

        case .started(let snapshot), .paused(let snapshot):
            latestSnapshot = snapshot
            await upsert(snapshot)

        case .phaseCompleted(let completionDate, let nextSnapshot):
            if let nextSnapshot {
                latestSnapshot = nextSnapshot
                await upsert(nextSnapshot)
            } else {
                latestSnapshot = nil
                await completeActivities(at: completionDate)
            }

        case .reset:
            latestSnapshot = nil
            await endAllImmediately()

        case .preferenceChanged(let isEnabled):
            if isEnabled, let latestSnapshot {
                await upsert(latestSnapshot)
            } else if !isEnabled {
                await endAllImmediately()
            }
        }
    }

    private var isPreferenceEnabled: Bool {
        !repository.contains(UserDefaultKeys.liveActivitiesEnabled)
            || repository.bool(for: UserDefaultKeys.liveActivitiesEnabled)
    }

    private func reconcile(_ snapshot: TimerActivitySnapshot?) async {
        guard isPreferenceEnabled else {
            await endAllImmediately()
            return
        }

        if let snapshot {
            await upsert(snapshot)
            return
        }

        let currentDate = nowProvider()
        for activity in client.activeActivities() {
            if activity.state.status == .running, activity.state.timerEndDate <= currentDate {
                await endCompletedActivity(activity, completionDate: activity.state.timerEndDate)
            } else {
                await client.end(identifier: activity.identifier, content: nil, dismissalPolicy: .immediate)
            }
        }
    }

    private func upsert(_ snapshot: TimerActivitySnapshot) async {
        guard isPreferenceEnabled, client.areActivitiesEnabled else { return }

        let state = snapshot.contentState
        let content = ActivityContent(
            state: state,
            staleDate: state.status == .running ? state.timerEndDate : nil,
            relevanceScore: 100
        )
        let activities = client.activeActivities()

        if let primaryActivity = activities.first {
            await client.update(identifier: primaryActivity.identifier, content: content)
            for duplicate in activities.dropFirst() {
                await client.end(identifier: duplicate.identifier, content: nil, dismissalPolicy: .immediate)
            }
            return
        }

        do {
            _ = try client.request(
                attributes: FocusedTimerActivityAttributes(identifier: UUID()),
                content: content
            )
        } catch {
            Self.logger.error("Unable to start Live Activity: \(error.localizedDescription)")
        }
    }

    private func completeActivities(at completionDate: Date) async {
        for activity in client.activeActivities() {
            await endCompletedActivity(activity, completionDate: completionDate)
        }
    }

    private func endCompletedActivity(_ activity: LiveActivityRecord, completionDate: Date) async {
        let completedState = activity.state.completed(at: completionDate)
        let content = ActivityContent(
            state: completedState,
            staleDate: nil,
            relevanceScore: 100
        )
        let dismissalDate = completionDate.addingTimeInterval(15 * 60)
        let policy: ActivityUIDismissalPolicy = dismissalDate <= nowProvider()
            ? .immediate
            : .after(dismissalDate)
        await client.end(identifier: activity.identifier, content: content, dismissalPolicy: policy)
    }

    private func endAllImmediately() async {
        for activity in client.activeActivities() {
            await client.end(identifier: activity.identifier, content: nil, dismissalPolicy: .immediate)
        }
    }
}

final class LiveActivityManager: LiveActivityManaging, @unchecked Sendable {
    static let shared = LiveActivityManager()

    private let coordinator: LiveActivityCoordinator
    private let lock = NSLock()
    private var sequence = 0

    init(coordinator: LiveActivityCoordinator = LiveActivityCoordinator()) {
        self.coordinator = coordinator
    }

    func handle(_ event: LiveActivityEvent) {
        lock.lock()
        let eventSequence = sequence
        sequence += 1
        lock.unlock()

        Task {
            await coordinator.enqueue(event, sequence: eventSequence)
        }
    }
}
