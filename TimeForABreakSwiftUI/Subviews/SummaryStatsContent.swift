//
//  SummaryStatsContent.swift
//  TimeForABreakSwiftUI
//

import SwiftUI

enum SummaryStatsFormatting {
    static func badgeText(for stats: SelectedActionsViewModel.ActionDailyStats) -> String {
        if let total = stats.totalQuantity, stats.action.isQuantifiable, let unit = stats.action.displayUnit(forQuantity: total) {
            return "\(total) \(unit)"
        }
        return "×\(stats.count)"
    }
}

/// Shared empty state for summary-style screens.
struct SummaryEmptyPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("You've got this! Start a break to log your first action.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Text("🍃")
                .font(.system(size: 64))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

/// Compact “Completed today” list for the companion sheet (collapsed).
struct CompletedTodayCompactStats: View {
    @EnvironmentObject private var selectActions: SelectedActionsViewModel

    private var todayStats: [SelectedActionsViewModel.ActionDailyStats] {
        selectActions.dailyStats(for: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Completed today")
                .font(.headline)
            if todayStats.isEmpty {
                Text("Nothing logged yet today.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(todayStats) { stats in
                            HStack(spacing: 6) {
                                Text(stats.action.title)
                                    .font(.caption)
                                    .lineLimit(2)
                                Spacer(minLength: 8)
                                Text(SummaryStatsFormatting.badgeText(for: stats))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 120)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Full today + yesterday stats (replaces inline logic in SummaryView).
struct SummaryStatsBody: View {
    @EnvironmentObject private var selectActions: SelectedActionsViewModel
    var showYesterday: Bool

    private let cal = Calendar.current

    private var todayStats: [SelectedActionsViewModel.ActionDailyStats] {
        selectActions.dailyStats(for: Date())
    }

    private var yesterdayStats: [SelectedActionsViewModel.ActionDailyStats] {
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return selectActions.dailyStats(for: yesterday)
    }

    var body: some View {
        Group {
            if todayStats.isEmpty && (!showYesterday || yesterdayStats.isEmpty) {
                SummaryEmptyPlaceholder()
            } else {
                List {
                    if !todayStats.isEmpty {
                        Section("Completed Today") {
                            ForEach(todayStats) { stats in
                                HStack(spacing: 6) {
                                    Text(stats.action.title)
                                        .font(.caption)
                                    Spacer(minLength: 8)
                                    Text(SummaryStatsFormatting.badgeText(for: stats))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    if showYesterday, !yesterdayStats.isEmpty {
                        Section("Completed Yesterday") {
                            ForEach(yesterdayStats) { stats in
                                HStack(spacing: 6) {
                                    Text(stats.action.title)
                                        .font(.caption)
                                    Spacer(minLength: 8)
                                    Text(SummaryStatsFormatting.badgeText(for: stats))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

/// Today-only summary for navigation from the companion menu.
struct TodaySummaryView: View {
    var body: some View {
        SummaryStatsBody(showYesterday: false)
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbars(title: "Today")
            }
    }
}

/// Yesterday-only summary for navigation from the companion menu.
struct YesterdaySummaryView: View {
    @EnvironmentObject private var selectActions: SelectedActionsViewModel

    private let cal = Calendar.current

    private var yesterdayStats: [SelectedActionsViewModel.ActionDailyStats] {
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return selectActions.dailyStats(for: yesterday)
    }

    var body: some View {
        Group {
            if yesterdayStats.isEmpty {
                SummaryEmptyPlaceholder()
            } else {
                List {
                    Section("Completed Yesterday") {
                        ForEach(yesterdayStats) { stats in
                            HStack(spacing: 6) {
                                Text(stats.action.title)
                                    .font(.caption)
                                Spacer(minLength: 8)
                                Text(SummaryStatsFormatting.badgeText(for: stats))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Yesterday")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbars(title: "Yesterday")
        }
    }
}
