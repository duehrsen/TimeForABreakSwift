//
//  TimerModelTests.swift
//  TimeForABreakSwiftUITests
//
//  Created on 2026-03-02.
//

import XCTest
@testable import Time_For_A_Break

@MainActor
final class TimerModelTests: XCTestCase {

    private var sut: TimerModel!

    override func setUp() {
        super.setUp()
        sut = TimerModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertTrue(sut.isWorkTime)
        XCTAssertFalse(sut.started)
        XCTAssertFalse(sut.isComplete)
        XCTAssertEqual(sut.progress, 1.0)
        XCTAssertEqual(sut.workTimeTotalSeconds, 1200) // 20 min
        XCTAssertEqual(sut.breakTimeTotalSeconds, 300)  // 5 min
    }

    // MARK: - formattedTime

    func testFormattedTimeDefault() {
        // After init, currentTimeRemaining is 120 (2 min)
        XCTAssertEqual(sut.formattedTime, "02:00")
    }

    func testFormattedTimeAfterReset() {
        sut.reset()
        // After reset in work mode, should be workTimeTotalSeconds = 1200 = 20:00
        XCTAssertEqual(sut.formattedTime, "20:00")
    }

    func testFormattedTimeAfterUpdateFromOptions() {
        sut.updateFromOptions(optionSet: OptionSet(breaktimeMin: 1, worktimeMin: 1, doesPlaySounds: false))
        // After updateFromOptions, reset is called, currentTimeRemaining = 60
        XCTAssertEqual(sut.formattedTime, "01:00")
    }

    // MARK: - start / pause / toggle

    func testStartSetsStartedTrue() {
        sut.start()
        XCTAssertTrue(sut.started)
        sut.pause() // clean up
    }

    func testPauseAfterStartSetsStartedFalse() {
        sut.start()
        sut.pause()
        XCTAssertFalse(sut.started)
    }

    func testToggleStartsThenPauses() {
        sut.toggle()
        XCTAssertTrue(sut.started)
        sut.toggle()
        XCTAssertFalse(sut.started)
    }

    func testStartWhenAlreadyStartedIsNoOp() {
        sut.start()
        XCTAssertTrue(sut.started)
        sut.start() // should not crash or change state
        XCTAssertTrue(sut.started)
        sut.pause()
    }

    func testPauseWhenNotStartedIsNoOp() {
        sut.pause()
        XCTAssertFalse(sut.started)
    }

    // MARK: - reset

    func testResetRestoresWorkModeDefaults() {
        sut.start()
        sut.reset()
        XCTAssertFalse(sut.started)
        XCTAssertEqual(sut.currentTimeRemaining, sut.workTimeTotalSeconds)
        XCTAssertEqual(sut.progress, 1.0)
        XCTAssertFalse(sut.isComplete)
    }

    func testResetInBreakModeRestoresBreakDefaults() {
        sut.switchMode() // now in break mode
        sut.start()
        sut.reset()
        XCTAssertFalse(sut.started)
        XCTAssertEqual(sut.currentTimeRemaining, sut.breakTimeTotalSeconds)
        XCTAssertEqual(sut.progress, 1.0)
    }

    // MARK: - switchMode

    func testSwitchModeTogglesIsWorkTime() {
        XCTAssertTrue(sut.isWorkTime)
        sut.switchMode()
        XCTAssertFalse(sut.isWorkTime)
        sut.switchMode()
        XCTAssertTrue(sut.isWorkTime)
    }

    func testSwitchModeSetsCorrectTimeRemaining() {
        sut.switchMode() // to break
        XCTAssertEqual(sut.currentTimeRemaining, sut.breakTimeTotalSeconds)
        sut.switchMode() // back to work
        XCTAssertEqual(sut.currentTimeRemaining, sut.workTimeTotalSeconds)
    }

    func testSwitchModePausesTimer() {
        sut.start()
        XCTAssertTrue(sut.started)
        sut.switchMode()
        XCTAssertFalse(sut.started)
    }

    func testSwitchModeResetsProgress() {
        sut.switchMode()
        XCTAssertEqual(sut.progress, 1.0)
    }

    // MARK: - updateFromOptions

    func testUpdateFromOptionsSetsNewDurations() {
        let options = OptionSet(breaktimeMin: 10, worktimeMin: 30, doesPlaySounds: false)
        sut.updateFromOptions(optionSet: options)
        XCTAssertEqual(sut.workTimeTotalSeconds, 1800)  // 30 * 60
        XCTAssertEqual(sut.breakTimeTotalSeconds, 600)   // 10 * 60
    }

    func testUpdateFromOptionsResetsTimer() {
        sut.start()
        let options = OptionSet(breaktimeMin: 10, worktimeMin: 25, doesPlaySounds: false)
        sut.updateFromOptions(optionSet: options)
        XCTAssertFalse(sut.started)
        XCTAssertEqual(sut.currentTimeRemaining, 1500) // 25 * 60
        XCTAssertEqual(sut.progress, 1.0)
    }

    // MARK: - skipForward

    func testSkipForwardWhenPausedIsNoOp() {
        sut.reset()
        let before = sut.currentTimeRemaining
        sut.skipForward(seconds: 60)
        XCTAssertEqual(sut.currentTimeRemaining, before)
    }

    func testSkipForwardDecrementsWhileStarted() {
        sut.reset()
        sut.start()
        sut.skipForward(seconds: 100)
        XCTAssertEqual(sut.currentTimeRemaining, sut.workTimeTotalSeconds - 100)
        XCTAssertFalse(sut.isComplete)
        sut.pause()
    }

    func testSkipForwardToZeroCompletes() {
        sut.updateFromOptions(optionSet: OptionSet(breaktimeMin: 1, worktimeMin: 1, doesPlaySounds: false))
        sut.start()
        sut.skipForward(seconds: 120)
        XCTAssertFalse(sut.started)
        XCTAssertTrue(sut.isComplete)
        XCTAssertEqual(sut.currentTimeRemaining, 0)
    }

    // MARK: - acknowledgeCompletion

    func testAcknowledgeCompletionClearsFlag() {
        sut.acknowledgeCompletion()
        XCTAssertFalse(sut.isComplete)
    }

    // MARK: - movingToBackground / movingToActive

    func testMovingToBackgroundWhenNotStartedIsNoOp() {
        sut.movingToBackground()
        XCTAssertFalse(sut.started)
    }

    func testMovingToActiveWhenNotStartedIsNoOp() {
        sut.movingToActive()
        XCTAssertFalse(sut.started)
    }

    func testMovingToActiveWithTimeRemaining() {
        sut.reset() // sets currentTimeRemaining to workTimeTotalSeconds
        sut.start()
        sut.movingToBackground()
        // Immediately call movingToActive (elapsed ~0 seconds)
        sut.movingToActive()
        XCTAssertTrue(sut.started)
        // Time remaining should be roughly the same (within 1 second tolerance)
        XCTAssertGreaterThan(sut.currentTimeRemaining, sut.workTimeTotalSeconds - 2)
        sut.pause()
    }

    // MARK: - totalSecondsForCurrentMode

    func testTotalSecondsForCurrentModeWork() {
        XCTAssertTrue(sut.isWorkTime)
        XCTAssertEqual(sut.totalSecondsForCurrentMode, sut.workTimeTotalSeconds)
    }

    func testTotalSecondsForCurrentModeBreak() {
        sut.switchMode()
        XCTAssertFalse(sut.isWorkTime)
        XCTAssertEqual(sut.totalSecondsForCurrentMode, sut.breakTimeTotalSeconds)
    }

    // MARK: - Countdown Integration (async)

    func testCountdownDecrementsAfterOneSecond() async throws {
        sut.reset() // currentTimeRemaining = workTimeTotalSeconds = 1200
        let initialTime = sut.currentTimeRemaining
        sut.start()

        // Wait slightly more than 1 second for the first tick
        try await Task.sleep(nanoseconds: 1_200_000_000)

        sut.pause()
        XCTAssertLessThan(sut.currentTimeRemaining, initialTime)
        XCTAssertGreaterThanOrEqual(sut.currentTimeRemaining, initialTime - 2)
    }
}
