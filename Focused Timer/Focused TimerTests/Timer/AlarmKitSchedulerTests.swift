//
//  AlarmKitSchedulerTests.swift
//  Focused TimerTests
//

import Foundation
import Testing
@testable import Focused_Timer

@MainActor
private final class AlarmIdentifierStoreSpy: AlarmIdentifierStoring {
    var alarmIdentifier: UUID?
}

@MainActor
private final class AlarmScheduleGate {
    private(set) var continuation: CheckedContinuation<Void, any Error>?

    func schedule(
        alarmID _: UUID,
        fireDate _: Date,
        title _: LocalizedStringResource
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
}

@Suite("AlarmKitScheduler")
@MainActor
struct AlarmKitSchedulerTests {

    @Test("Cancelling an in-flight schedule removes an alarm that completes late")
    func cancellingInFlightScheduleRemovesLateAlarm() async throws {
        let alarmID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let store = AlarmIdentifierStoreSpy()
        let gate = AlarmScheduleGate()
        var cancelledIdentifiers: [UUID] = []
        let scheduler = AlarmKitScheduler(
            authorizationProvider: { true },
            identifierStore: store,
            uuidProvider: { alarmID },
            scheduleOperation: gate.schedule,
            cancelOperation: { cancelledIdentifiers.append($0) }
        )

        scheduler.scheduleAlarm(remainingTime: 60, timerType: .focused)
        for _ in 0..<10 where gate.continuation == nil {
            await Task.yield()
        }
        let continuation = try #require(gate.continuation)

        scheduler.cancelAlarm()
        #expect(store.alarmIdentifier == nil)
        #expect(cancelledIdentifiers == [alarmID])

        continuation.resume()
        await Task.yield()
        await Task.yield()

        #expect(cancelledIdentifiers == [alarmID, alarmID])
    }

    @Test("A persisted alarm identifier is cancelled precisely during initialization")
    func persistedIdentifierIsCancelledOnInitialization() {
        let alarmID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let store = AlarmIdentifierStoreSpy()
        store.alarmIdentifier = alarmID
        var cancelledIdentifiers: [UUID] = []

        _ = AlarmKitScheduler(
            authorizationProvider: { true },
            identifierStore: store,
            cancelOperation: { cancelledIdentifiers.append($0) }
        )

        #expect(cancelledIdentifiers == [alarmID])
        #expect(store.alarmIdentifier == nil)
    }
}
