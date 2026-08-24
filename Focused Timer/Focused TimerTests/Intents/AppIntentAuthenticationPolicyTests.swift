//
//  AppIntentAuthenticationPolicyTests.swift
//  Focused TimerTests
//

import AppIntents
import Testing
@testable import Focused_Timer

@Suite("App Intent Authentication Policies")
struct AppIntentAuthenticationPolicyTests {

    @Test("Timer controls remain available from locked system surfaces")
    func timerControlsAreExplicitlyAllowed() {
        #expect(StartTimerIntent.authenticationPolicy == .alwaysAllowed)
        #expect(PauseTimerIntent.authenticationPolicy == .alwaysAllowed)
        #expect(ResumeTimerIntent.authenticationPolicy == .alwaysAllowed)
        #expect(ResetTimerIntent.authenticationPolicy == .alwaysAllowed)
        #expect(FocusedTimerFocusFilterIntent.authenticationPolicy == .alwaysAllowed)
    }

    @Test("Status and settings intents require authentication")
    func statusAndSettingsRequireAuthentication() {
        #expect(GetTimerStatusIntent.authenticationPolicy == .requiresAuthentication)
        #expect(SetTimerDurationIntent.authenticationPolicy == .requiresAuthentication)
        #expect(SetNumberOfCyclesIntent.authenticationPolicy == .requiresAuthentication)
        #expect(ToggleAutoStartIntent.authenticationPolicy == .requiresAuthentication)
        #expect(ToggleSoundIntent.authenticationPolicy == .requiresAuthentication)
        #expect(ResetSettingsIntent.authenticationPolicy == .requiresAuthentication)
    }
}
