//
//  TimeForABreakWidgetsLiveActivity.swift
//  TimeForABreakWidgets
//

import ActivityKit
import SwiftUI
import WidgetKit

struct TimeForABreakWidgetsLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BreakTimerAttributes.self) { context in
            // Lock screen / banner presentation
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(
                        context.state.isWorkTime ? "WORK" : "BREAK",
                        systemImage: context.state.isWorkTime ? "brain" : "cup.and.saucer.fill"
                    )
                    .font(.caption2)
                    .foregroundColor(context.state.isWorkTime ? .blue : .orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timerText(context: context)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.center) {
                    ProgressView(value: context.state.progress)
                        .tint(context.state.isWorkTime ? .blue : .orange)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.actionPreview)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Label(
                    context.state.isWorkTime ? "W" : "B",
                    systemImage: context.state.isWorkTime ? "brain" : "cup.and.saucer.fill"
                )
                .font(.caption2)
                .foregroundColor(context.state.isWorkTime ? .blue : .orange)
            } compactTrailing: {
                timerText(context: context)
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: context.state.isWorkTime ? "brain" : "cup.and.saucer.fill")
                    .font(.caption2)
                    .foregroundColor(context.state.isWorkTime ? .blue : .orange)
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<BreakTimerAttributes>) -> some View {
        let isWork = context.state.isWorkTime
        let accentColor: Color = isWork ? .blue : .orange

        VStack(spacing: 8) {
            HStack {
                Label(
                    isWork ? "WORK" : "BREAK",
                    systemImage: isWork ? "brain" : "cup.and.saucer.fill"
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(accentColor)

                Spacer()

                timerText(context: context)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundColor(.primary)
            }

            ProgressView(value: context.state.progress)
                .tint(accentColor)

            Text(context.attributes.actionPreview)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(16)
        .activityBackgroundTint(isWork ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
    }

    // MARK: - Timer Text Helper

    @ViewBuilder
    private func timerText(context: ActivityViewContext<BreakTimerAttributes>) -> some View {
        if context.state.isRunning, let endDate = context.state.timerEndDate {
            Text(timerInterval: Date()...endDate, countsDown: true)
        } else {
            let minutes = context.state.timeRemaining / 60
            let seconds = context.state.timeRemaining % 60
            Text(String(format: "%02d:%02d", minutes, seconds))
        }
    }
}

// MARK: - Previews

extension BreakTimerAttributes {
    fileprivate static var preview: BreakTimerAttributes {
        BreakTimerAttributes(actionPreview: "Next: Drink water", totalSeconds: 1200)
    }
}

extension BreakTimerAttributes.ContentState {
    fileprivate static var workRunning: BreakTimerAttributes.ContentState {
        BreakTimerAttributes.ContentState(
            isWorkTime: true,
            isRunning: true,
            timerEndDate: Date().addingTimeInterval(745),
            timeRemaining: 745,
            progress: 0.62
        )
    }

    fileprivate static var breakRunning: BreakTimerAttributes.ContentState {
        BreakTimerAttributes.ContentState(
            isWorkTime: false,
            isRunning: true,
            timerEndDate: Date().addingTimeInterval(272),
            timeRemaining: 272,
            progress: 0.91
        )
    }
}

#Preview("Notification", as: .content, using: BreakTimerAttributes.preview) {
    TimeForABreakWidgetsLiveActivity()
} contentStates: {
    BreakTimerAttributes.ContentState.workRunning
    BreakTimerAttributes.ContentState.breakRunning
}
