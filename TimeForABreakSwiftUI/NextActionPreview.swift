//
//  NextActionPreview.swift
//  TimeForABreakSwiftUI
//

import Foundation

/// Short line for Live Activity, timer screen, etc. — matches suggestion-set priority then any remaining action.
enum NextActionPreview {
    static func line(
        options: OptionSet,
        actions: [BreakAction],
        calendar: Calendar = .current,
        now: Date = Date()
    ) -> String {
        let today = calendar.startOfDay(for: now)

        let suggestedTitles: Set<String>
        if let titles = options.dailySuggestedTitles, !titles.isEmpty {
            suggestedTitles = Set(titles)
        } else {
            suggestedTitles = Set(DataProvider.defaultDailySuggestedActionTitles())
        }

        let uncompletedTodayOrPinned = actions.filter {
            (calendar.isDate($0.date ?? .distantPast, inSameDayAs: today) || $0.pinned) && !$0.completed
        }

        if let suggestedNext = uncompletedTodayOrPinned.first(where: { suggestedTitles.contains($0.title) }) {
            return "Next: \(suggestedNext.title)"
        }

        if let anyNext = uncompletedTodayOrPinned.first {
            return "Next: \(anyNext.title)"
        }

        return "Focus time"
    }
}
