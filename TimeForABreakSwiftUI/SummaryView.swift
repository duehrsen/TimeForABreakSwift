//
//  SummaryView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-08.
//

import SwiftUI

struct SummaryView: View {

    @EnvironmentObject var selectActions: SelectedActionsViewModel

    let cal = Calendar.current

    private var todayStats: [SelectedActionsViewModel.ActionDailyStats] {
        selectActions.dailyStats(for: Date())
    }

    private var yesterdayStats: [SelectedActionsViewModel.ActionDailyStats] {
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return selectActions.dailyStats(for: yesterday)
    }

    var body: some View {
        NavigationStack {
            Group {
                if todayStats.isEmpty && yesterdayStats.isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Text("You've got this! Start a break to log your first action.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            Text("🍃")
                                .font(.system(size: 64))
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if !todayStats.isEmpty {
                            Section("Completed Today") {
                                ForEach(todayStats) { stats in
                                    HStack(spacing: 6) {
                                        Text(stats.action.title)
                                            .font(.caption)
                                        .badge(badgeText(for: stats))
                                    }
                                }
                            }
                        }
                        if !yesterdayStats.isEmpty {
                            Section("Completed Yesterday") {
                                ForEach(yesterdayStats) { stats in
                                    HStack(spacing: 6) {
                                        Text(stats.action.title)
                                            .font(.caption)
                                        .badge(badgeText(for: stats))
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbars(title: "Summary")
            }
        }
    }

    private func badgeText(for stats: SelectedActionsViewModel.ActionDailyStats) -> String {
        if let total = stats.totalQuantity, stats.action.isQuantifiable, let unit = stats.action.displayUnit(forQuantity: total) {
            return "\(total) \(unit)"
        }
        return "×\(stats.count)"
    }
}
