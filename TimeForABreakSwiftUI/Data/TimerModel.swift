//
//  TimerModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-27.
//

import Combine
import SwiftUI

@MainActor
class TimerModel: ObservableObject {

    // MARK: - Published State (read-only to views)

    @Published private(set) var currentTimeRemaining: Int = 120
    @Published private(set) var progress: CGFloat = 1.0
    @Published private(set) var isWorkTime: Bool = true
    @Published private(set) var started: Bool = false
    @Published private(set) var isComplete: Bool = false

    // MARK: - Configuration

    private(set) var workTimeTotalSeconds: Int = 60 * 20
    private(set) var breakTimeTotalSeconds: Int = 60 * 5

    // MARK: - Internal State

    private var timerTask: Task<Void, Never>?
    private var unfocusDate: Date = Date()

    /// The total seconds for the current mode (work or break).
    var totalSecondsForCurrentMode: Int {
        isWorkTime ? workTimeTotalSeconds : breakTimeTotalSeconds
    }

    // MARK: - Computed Properties

    /// Formats currentTimeRemaining as "MM:SS".
    var formattedTime: String {
        let minutes = currentTimeRemaining / 60
        let seconds = currentTimeRemaining % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }

    // MARK: - Timer Control Methods

    func start() {
        guard !started else { return }
        started = true
        isComplete = false
        startCountdown()
    }

    func pause() {
        guard started else { return }
        started = false
        timerTask?.cancel()
        timerTask = nil
    }

    func toggle() {
        if started {
            pause()
        } else {
            start()
        }
    }

    func reset() {
        pause()
        currentTimeRemaining = totalSecondsForCurrentMode
        progress = 1.0
        isComplete = false
    }

    func switchMode() {
        pause()
        isWorkTime.toggle()
        currentTimeRemaining = totalSecondsForCurrentMode
        progress = 1.0
        isComplete = false
    }

    /// Called by the view after it has presented the completion sheet.
    func acknowledgeCompletion() {
        isComplete = false
    }

    // MARK: - Options

    func updateFromOptions(optionSet: OptionSet) {
        workTimeTotalSeconds = optionSet.worktimeMin * 60
        breakTimeTotalSeconds = optionSet.breaktimeMin * 60
        reset()
    }

    // MARK: - Background / Foreground

    func movingToBackground() {
        if started {
            unfocusDate = Date()
        }
    }

    func movingToActive() {
        guard started else { return }

        let elapsed = Int(Date().timeIntervalSince(unfocusDate))
        let remaining = currentTimeRemaining - elapsed

        if remaining <= 0 {
            // Timer expired while backgrounded
            timerTask?.cancel()
            timerTask = nil
            started = false
            isComplete = true
        } else {
            currentTimeRemaining = remaining
            progress = CGFloat(remaining) / CGFloat(totalSecondsForCurrentMode)
            // Restart the countdown task since Task.sleep would have
            // been suspended/inaccurate while backgrounded
            timerTask?.cancel()
            startCountdown()
        }
    }

    // MARK: - Private

    private func startCountdown() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                guard let self = self else { break }

                if self.currentTimeRemaining > 0 {
                    self.currentTimeRemaining -= 1
                    self.progress = CGFloat(self.currentTimeRemaining) /
                        CGFloat(self.totalSecondsForCurrentMode)
                }

                if self.currentTimeRemaining <= 0 {
                    self.started = false
                    self.isComplete = true
                    self.timerTask = nil
                    break
                }
            }
        }
    }
}
