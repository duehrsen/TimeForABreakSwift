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
    private var completionDismissTask: Task<Void, Never>?

    private static let completionDisplaySeconds: UInt64 = 5

    private func cancelCompletionDismissTask() {
        completionDismissTask?.cancel()
        completionDismissTask = nil
    }

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
            progress: Double(timeRemaining) / Double(totalSeconds),
            isTimerFinished: false
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
            progress: Double(timeRemaining) / Double(totalSeconds),
            isTimerFinished: false
        )

        let staleDate = endDate ?? Date().addingTimeInterval(3600)
        let content = ActivityContent(state: state, staleDate: staleDate)

        Task {
            await activity.update(content)
        }
    }

    // MARK: - Completion (checkmark, then dismiss)

    /// Updates the Live Activity to a finished state (lock screen checkmark), then ends after a short delay.
    func showTimerFinishedThenEnd(isWorkTime: Bool, totalSeconds: Int) {
        cancelCompletionDismissTask()
        guard let activity = currentActivity else { return }

        let finishedState = BreakTimerAttributes.ContentState(
            isWorkTime: isWorkTime,
            isRunning: false,
            timerEndDate: nil,
            timeRemaining: 0,
            progress: totalSeconds > 0 ? 1.0 : 0.0,
            isTimerFinished: true
        )
        let staleDate = Date().addingTimeInterval(TimeInterval(Self.completionDisplaySeconds))
        let updateContent = ActivityContent(state: finishedState, staleDate: staleDate)

        Task {
            await activity.update(updateContent)
        }

        let activityId = activity.id
        let sleepNanoseconds = Self.completionDisplaySeconds * 1_000_000_000
        completionDismissTask = Task { [weak self] in
            guard let self else { return }
            defer { self.completionDismissTask = nil }
            do {
                try await Task.sleep(nanoseconds: sleepNanoseconds)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            guard self.currentActivity?.id == activityId else { return }

            let endState = BreakTimerAttributes.ContentState(
                isWorkTime: isWorkTime,
                isRunning: false,
                timerEndDate: nil,
                timeRemaining: 0,
                progress: 0.0,
                isTimerFinished: false
            )
            let endContent = ActivityContent(state: endState, staleDate: nil)
            await activity.end(endContent, dismissalPolicy: .immediate)

            if self.currentActivity?.id == activityId {
                self.currentActivity = nil
                self.isActivityActive = false
            }
        }
    }

    // MARK: - End

    func endActivity() {
        cancelCompletionDismissTask()
        guard let activity = currentActivity else { return }

        let finalState = BreakTimerAttributes.ContentState(
            isWorkTime: false,
            isRunning: false,
            timerEndDate: nil,
            timeRemaining: 0,
            progress: 0.0,
            isTimerFinished: false
        )

        let content = ActivityContent(state: finalState, staleDate: nil)

        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }

        currentActivity = nil
        isActivityActive = false
    }
}
