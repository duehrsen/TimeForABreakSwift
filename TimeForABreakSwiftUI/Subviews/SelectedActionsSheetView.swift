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
                Section(isFromCompletedSheet ? "Check off any you've done!" : "Your actions for today") {
                }
                ForEach(sortedTodayActions, id: \.id) {
                    item in
                    ActionCompletionRowView(action: item, editable: true)
                }
                .onDelete(perform: selectActions.deleteAction)
            }.listStyle(.plain)
        }
    }
}
