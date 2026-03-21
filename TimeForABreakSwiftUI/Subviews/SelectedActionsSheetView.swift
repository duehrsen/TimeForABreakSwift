//
//  SelectedActionsSheetView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-10.
//

import SwiftUI

struct SelectedActionsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var selectActions : SelectedActionsViewModel
    @EnvironmentObject var optionsModel: OptionsModel
    
    var isFromCompletedSheet : Bool = false
    
    let cal = Calendar.current
    
    private var suggestedTitles: Set<String> {
        if let titles = optionsModel.options.dailySuggestedTitles,
           !titles.isEmpty {
            return Set(titles)
        } else {
            return Set(DataProvider.defaultDailySuggestedActionTitles())
        }
    }

    private var sortedTodayActions: [BreakAction] {
        let todayActions = selectActions.actions.filter {
            cal.isDateInToday($0.date ?? .distantPast) || $0.pinned
        }

        return todayActions.sorted { lhs, rhs in
            let lhsIsSuggestedPinned = lhs.pinned && suggestedTitles.contains(lhs.title)
            let rhsIsSuggestedPinned = rhs.pinned && suggestedTitles.contains(rhs.title)

            if lhsIsSuggestedPinned != rhsIsSuggestedPinned {
                return lhsIsSuggestedPinned && !rhsIsSuggestedPinned
            }

            if lhs.pinned != rhs.pinned {
                return lhs.pinned && !rhs.pinned
            }

            return lhs.title < rhs.title
        }
    }

    var body: some View {
        VStack {
            List {
                let actions = sortedTodayActions
                if actions.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Text("No actions planned yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Plan your day from the \"Plan your day\" screen or Options → Manage break actions.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                    }
                } else {
                    Section(isFromCompletedSheet ? "Check off any you've done!" : "Your actions for today") {
                        ForEach(actions, id: \.id) { item in
                            ActionCompletionRowView(action: item, editable: true)
                        }
                        .onDelete { offsets in
                            selectActions.deleteDisplayedTodayActions(at: offsets, displayedInOrder: actions)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
