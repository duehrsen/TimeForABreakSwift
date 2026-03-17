//
//  SummaryView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-08.
//

import SwiftUI

struct SummaryView: View {
    
    @EnvironmentObject var selectActions : SelectedActionsViewModel
    
    let cal = Calendar.current
    
    var body: some View {
        NavigationStack {
            VStack{
                List {
                    Section("Completed Today") {
                        ForEach(selectActions.dailyStats(for: Date())) { stats in
                            HStack(spacing: 6) {
                                Text(stats.action.title)
                                    .font(.caption)
                                    .badge(badgeText(for: stats))
                            }
                        }
                    }
                    Section("Completed Yesterday") {
                        let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                        ForEach(selectActions.dailyStats(for: yesterday)) { stats in
                            HStack(spacing: 6) {
                                Text(stats.action.title)
                                    .font(.caption)
                                    .badge(badgeText(for: stats))
                            }
                        }
                    }
                }.listStyle(.insetGrouped)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
               toolbars(title: "Summary")
            }
        }
        
    }

    private func badgeText(for stats: SelectedActionsViewModel.ActionDailyStats) -> String {
        if let total = stats.totalQuantity, stats.action.isQuantifiable, let unit = stats.action.unit {
            return "\(total) \(unit)"
        }
        return "×\(stats.count)"
    }
}
