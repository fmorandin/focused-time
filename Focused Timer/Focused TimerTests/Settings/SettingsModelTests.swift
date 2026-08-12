//
//  SettingsModelTests.swift
//  Focused TimerTests
//
//  Tests for SettingsModel — validates that minute→second conversion is applied
//  correctly on save, that default values are returned for unknown/unset keys,
//  and that all get/save round-trips work.
//

import ActivityKit
import Foundation
import Testing
@testable import Focused_Timer

// MARK: - Tests

@Suite("SettingsModel Tests", .serialized)
struct SettingsModelTests {

    // MARK: - saveTime / getTime round-trip

    @Test("saveTime converts minutes to seconds before persisting")
    func saveTimeConvertsToSeconds() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveTime(time: 25, for: UserDefaultKeys.focusedTime)

        // 25 minutes → 1500 seconds
        #expect(repo.integer(for: UserDefaultKeys.focusedTime) == 1500)
    }

    @Test("getTime returns the stored seconds value directly when non-zero")
    func getTimeReturnsStoredValue() {
        let repo = InMemoryStorageRepository()
        repo.save(1800, for: UserDefaultKeys.focusedTime)
        let model = SettingsModel(repository: repo)

        #expect(model.getTime(for: UserDefaultKeys.focusedTime) == 1800)
    }

    // MARK: - getTime defaults

    @Test("getTime returns default focused time when nothing is stored")
    func getTimeDefaultFocused() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultFocusedTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.focusedTime) == expected)
    }

    @Test("getTime returns default short break time when nothing is stored")
    func getTimeDefaultShortBreak() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultShortBreakTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.shortBreakTime) == expected)
    }

    @Test("getTime returns default long break time when nothing is stored")
    func getTimeDefaultLongBreak() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultLongBreakTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.longBreakTime) == expected)
    }

    @Test("getTime returns zero for an unrecognised key with no stored value")
    func getTimeUnknownKeyReturnsZero() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        #expect(model.getTime(for: "unknownTimeKey") == 0)
    }

    // MARK: - saveNumberOfCycles / getNumberOfCycles

    @Test("saveNumberOfCycles persists the raw integer value")
    func saveNumberOfCyclesPersistsValue() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveNumberOfCycles(numberOfCycles: 6, for: UserDefaultKeys.numberOfCycles)

        #expect(repo.integer(for: UserDefaultKeys.numberOfCycles) == 6)
    }

    @Test("getNumberOfCycles returns stored string when non-empty")
    func getNumberOfCyclesReturnsStoredValue() {
        let repo = InMemoryStorageRepository()
        repo.save("3", for: UserDefaultKeys.numberOfCycles)
        let model = SettingsModel(repository: repo)

        #expect(model.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == "3")
    }

    @Test("getNumberOfCycles returns default string when nothing is stored")
    func getNumberOfCyclesReturnsDefault() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = "\(DefaultValuesConstants.defaultNumberOfCycles.rawValue)"
        #expect(model.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == expected)
    }

    // MARK: - saveToggle / getToggle

    @Test("saveToggle persists true value")
    func saveTogglePersistsTrue() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveToggle(value: true, for: UserDefaultKeys.autoStartToggle)

        #expect(repo.bool(for: UserDefaultKeys.autoStartToggle) == true)
    }

    @Test("saveToggle persists false value")
    func saveTogglePersistsFalse() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveToggle(value: false, for: UserDefaultKeys.autoStartToggle)

        #expect(repo.bool(for: UserDefaultKeys.autoStartToggle) == false)
    }

    @Test("getToggle returns false when nothing is stored")
    func getToggleDefaultsFalse() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        #expect(model.getToggle(for: UserDefaultKeys.keepScreenOn) == false)
    }

    @Test("getToggle round-trips with saveToggle")
    func getToggleRoundTrip() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveToggle(value: true, for: UserDefaultKeys.keepScreenOn)
        #expect(model.getToggle(for: UserDefaultKeys.keepScreenOn) == true)
    }

    @Test("Live Activities default to enabled when the persisted key is missing")
    func liveActivitiesDefaultEnabled() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        #expect(model.getLiveActivitiesEnabled())
    }

    @Test("Live Activities preserve an explicitly disabled preference")
    func liveActivitiesPreserveDisabledPreference() {
        let repository = InMemoryStorageRepository()
        let model = SettingsModel(repository: repository)

        model.saveLiveActivitiesEnabled(false)

        #expect(repository.contains(UserDefaultKeys.liveActivitiesEnabled))
        #expect(!model.getLiveActivitiesEnabled())
    }
}

@Suite("Live Activity Tests", .serialized)
struct LiveActivityTests {

    private struct EndRecord {
        let identifier: String
        let content: ActivityContent<FocusedTimerActivityAttributes.ContentState>?
        let policyDescription: String
    }

    private final class ClientSpy: LiveActivityClient, @unchecked Sendable {
        var areActivitiesEnabled = true
        var activities: [LiveActivityRecord] = []
        var requestedContents: [ActivityContent<FocusedTimerActivityAttributes.ContentState>] = []
        var updatedContents: [(String, ActivityContent<FocusedTimerActivityAttributes.ContentState>)] = []
        var endedActivities: [EndRecord] = []
        var requestError: (any Error)?

        func activeActivities() -> [LiveActivityRecord] { activities }

        func request(
            attributes _: FocusedTimerActivityAttributes,
            content: ActivityContent<FocusedTimerActivityAttributes.ContentState>
        ) throws -> String {
            if let requestError { throw requestError }
            requestedContents.append(content)
            let identifier = "requested-activity"
            activities.append(LiveActivityRecord(identifier: identifier, state: content.state))
            return identifier
        }

        func update(
            identifier: String,
            content: ActivityContent<FocusedTimerActivityAttributes.ContentState>
        ) async {
            updatedContents.append((identifier, content))
            if let index = activities.firstIndex(where: { $0.identifier == identifier }) {
                activities[index] = LiveActivityRecord(identifier: identifier, state: content.state)
            }
        }

        func end(
            identifier: String,
            content: ActivityContent<FocusedTimerActivityAttributes.ContentState>?,
            dismissalPolicy: ActivityUIDismissalPolicy
        ) async {
            endedActivities.append(
                EndRecord(
                    identifier: identifier,
                    content: content,
                    policyDescription: String(describing: dismissalPolicy)
                )
            )
            activities.removeAll { $0.identifier == identifier }
        }
    }

    private enum TestError: Error { case requestFailed }

    private let referenceDate = Date(timeIntervalSince1970: 1_800_000_000)

    @Test("Content state calculates running, paused, completed, and long durations")
    @MainActor
    func contentStateCalculations() {
        let snapshot = makeSnapshot(status: .running, totalTime: 36_000, remainingTime: 32_400)
        let running = snapshot.contentState
        #expect(running.remainingTime(at: referenceDate) == 32_400)
        #expect(running.progress(at: referenceDate) == 0.9)

        let paused = makeSnapshot(status: .paused, remainingTime: 600).contentState
        #expect(paused.remainingTime(at: referenceDate.addingTimeInterval(300)) == 600)
        #expect(paused.pauseDate == referenceDate)

        let completed = running.completed(at: referenceDate)
        #expect(completed.status == .completed)
        #expect(completed.remainingTime(at: referenceDate) == 0)
        #expect(completed.completionDate == referenceDate)
        #expect(LiveActivityCountdownText.formatted(36_061) == "10:01:01")
    }

    @Test("Starting requests one activity and later state changes update it")
    func requestThenUpdate() async {
        let client = ClientSpy()
        let coordinator = makeCoordinator(client: client)

        await coordinator.handle(.started(makeSnapshot(status: .running)))
        await coordinator.handle(.paused(makeSnapshot(status: .paused, remainingTime: 900)))

        #expect(client.requestedContents.count == 1)
        #expect(client.updatedContents.count == 1)
        #expect(client.updatedContents.first?.1.state.status == .paused)
    }

    @Test("System-disabled activities and request failures never disrupt timer events")
    func unavailableAndRequestFailure() async {
        let unavailableClient = ClientSpy()
        unavailableClient.areActivitiesEnabled = false
        await makeCoordinator(client: unavailableClient).handle(.started(makeSnapshot()))
        #expect(unavailableClient.requestedContents.isEmpty)

        let failingClient = ClientSpy()
        failingClient.requestError = TestError.requestFailed
        await makeCoordinator(client: failingClient).handle(.started(makeSnapshot()))
        #expect(failingClient.activities.isEmpty)
    }

    @Test("Duplicate activities are collapsed to one on update")
    func duplicatePrevention() async {
        let client = ClientSpy()
        let state = makeSnapshot().contentState
        client.activities = [
            LiveActivityRecord(identifier: "primary", state: state),
            LiveActivityRecord(identifier: "duplicate", state: state)
        ]

        await makeCoordinator(client: client).handle(.started(makeSnapshot(remainingTime: 500)))

        #expect(client.updatedContents.map(\.0) == ["primary"])
        #expect(client.endedActivities.map(\.identifier) == ["duplicate"])
    }

    @Test("Preference opt-out ends immediately and missing preference defaults on")
    func preferenceBehavior() async {
        let client = ClientSpy()
        let coordinator = makeCoordinator(client: client)
        await coordinator.handle(.started(makeSnapshot()))
        #expect(client.requestedContents.count == 1)

        await coordinator.handle(.preferenceChanged(false))
        #expect(client.endedActivities.count == 1)

        let disabledRepository = InMemoryStorageRepository()
        disabledRepository.save(false, for: UserDefaultKeys.liveActivitiesEnabled)
        let disabledClient = ClientSpy()
        let disabledCoordinator = makeCoordinator(client: disabledClient, repository: disabledRepository)
        await disabledCoordinator.handle(.started(makeSnapshot()))
        #expect(disabledClient.requestedContents.isEmpty)
    }

    @Test("Normal completion publishes a summary with a fifteen-minute dismissal")
    func completionSummary() async {
        let client = ClientSpy()
        let state = makeSnapshot().contentState
        client.activities = [LiveActivityRecord(identifier: "activity", state: state)]

        await makeCoordinator(client: client).handle(
            .phaseCompleted(completionDate: referenceDate, nextSnapshot: nil)
        )

        #expect(client.endedActivities.count == 1)
        #expect(client.endedActivities.first?.content?.state.status == .completed)
        #expect(client.endedActivities.first?.content?.state.completionDate == referenceDate)
        let immediatePolicy = String(describing: ActivityUIDismissalPolicy.immediate)
        #expect(client.endedActivities.first?.policyDescription != immediatePolicy)
    }

    @Test("Relaunch reconciles expired activities and recreates a missing long timer")
    func relaunchAndLongTimerRecovery() async {
        let expiredClient = ClientSpy()
        let expiredState = makeSnapshot(remainingTime: 0).contentState
        expiredClient.activities = [LiveActivityRecord(identifier: "expired", state: expiredState)]
        await makeCoordinator(client: expiredClient).handle(.reconcile(nil))
        #expect(expiredClient.endedActivities.first?.content?.state.status == .completed)

        let recoveredClient = ClientSpy()
        await makeCoordinator(client: recoveredClient).handle(
            .reconcile(makeSnapshot(totalTime: 36_000, remainingTime: 30_000))
        )
        #expect(recoveredClient.requestedContents.count == 1)
        #expect(recoveredClient.requestedContents.first?.state.remainingTime(at: referenceDate) == 30_000)
    }

    @Test("Rapid events are serialized in sequence order")
    func rapidEventSerialization() async {
        let client = ClientSpy()
        let coordinator = makeCoordinator(client: client)

        async let pause: Void = coordinator.enqueue(
            .paused(makeSnapshot(status: .paused, remainingTime: 800)),
            sequence: 1
        )
        async let start: Void = coordinator.enqueue(.started(makeSnapshot()), sequence: 0)
        _ = await (pause, start)

        #expect(client.requestedContents.first?.state.status == .running)
        #expect(client.updatedContents.last?.1.state.status == .paused)
    }

    private func makeCoordinator(
        client: ClientSpy,
        repository: InMemoryStorageRepository = InMemoryStorageRepository()
    ) -> LiveActivityCoordinator {
        let currentDate = referenceDate
        return LiveActivityCoordinator(client: client, repository: repository, nowProvider: { currentDate })
    }

    private func makeSnapshot(
        status: TimerActivityStatus = .running,
        totalTime: Int = 1_500,
        remainingTime: Int = 1_200
    ) -> TimerActivitySnapshot {
        TimerActivitySnapshot(
            phase: .focused,
            status: status,
            totalTime: totalTime,
            remainingTime: remainingTime,
            completedCycles: 1,
            totalCycles: 4,
            capturedAt: referenceDate
        )
    }
}
