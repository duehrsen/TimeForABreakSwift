//
//  BreakTimerAttributes.swift
//  TimeForABreakSwiftUI
//

import ActivityKit
import Foundation

struct BreakTimerAttributes: ActivityAttributes {

    /// Total seconds for the full timer interval (used to calculate progress)
    var totalSeconds: Int

    struct ContentState: Codable, Hashable {
        /// Whether the user is in work mode or break mode
        var isWorkTime: Bool

        /// Whether the timer is actively counting down
        var isRunning: Bool

        /// The Date at which the timer will reach zero.
        /// Non-nil when running (for Text(.timerInterval:)), nil when paused.
        var timerEndDate: Date?

        /// Seconds remaining (used when paused for static display)
        var timeRemaining: Int

        /// Progress from 0.0 to 1.0
        var progress: Double

        /// True briefly when the interval reached zero; Live Activity shows completion UI before ending.
        var isTimerFinished: Bool

        /// Next-action line on Dynamic Island / lock screen; empty when disabled in settings.
        var actionPreview: String
    }
}
