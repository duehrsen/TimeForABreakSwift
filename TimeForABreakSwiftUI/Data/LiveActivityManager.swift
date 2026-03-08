//
//  LiveActivityManager.swift
//  TimeForABreakSwiftUI
//

import ActivityKit
import Combine
import Foundation

/// Manages the Live Activity lifecycle for the timer.
/// Only updates ActivityKit on meaningful state changes (start, pause, resume, end),
/// not every second — the widget uses Text(.timerInterval:) for live countdown.
@MainActor
class LiveActivityManager: ObservableObject {

    @Published private(set) var isActivityActive: Bool = false

    private var currentActivity: Activity<BreakTimerAttributes>?

    // MARK: - Start

    func startActivity(
        isWorkTime: Bool,
        timeRemaining: Int,
        totalSeconds: Int,
        actionPreview: String
    ) {
        endActivity()

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        let attributes = BreakTimerAttributes(
            actionPreview: actionPreview,
            totalSeconds: totalSeconds
        )

        let endDate = Date().addingTimeInterval(TimeInterval(timeRemaining))

        let state = BreakTimerAttributes.ContentState(
            isWorkTime: isWorkTime,
            isRunning: true,
            timerEndDate: endDate,
            timeRemaining: timeRemaining,
            progress: Double(timeRemaining) / Double(totalSeconds)
        )

        let content = ActivityContent(state: state, staleDate: endDate)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            isActivityActive = true
        } catch {
            print("[LiveActivityManager] Failed to start: \(error.localizedDescription)")
        }
    }

    // MARK: - Update

    func updateActivity(
        isWorkTime: Bool,
        isRunning: Bool,
        timeRemaining: Int,
        totalSeconds: Int
    ) {
        guard let activity = currentActivity else { return }

        let endDate = isRunning
            ? Date().addingTimeInterval(TimeInterval(timeRemaining))
            : nil

        let state = BreakTimerAttributes.ContentState(
            isWorkTime: isWorkTime,
            isRunning: isRunning,
            timerEndDate: endDate,
            timeRemaining: timeRemaining,
            progress: Double(timeRemaining) / Double(totalSeconds)
        )

        let staleDate = endDate ?? Date().addingTimeInterval(3600)
        let content = ActivityContent(state: state, staleDate: staleDate)

        Task {
            await activity.update(content)
        }
    }

    // MARK: - End

    func endActivity() {
        guard let activity = currentActivity else { return }

        let finalState = BreakTimerAttributes.ContentState(
            isWorkTime: false,
            isRunning: false,
            timerEndDate: nil,
            timeRemaining: 0,
            progress: 0.0
        )

        let content = ActivityContent(state: finalState, staleDate: nil)

        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }

        currentActivity = nil
        isActivityActive = false
    }
}
