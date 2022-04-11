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
    
    let cal = Calendar.current
    
    var body: some View {
        VStack {
            //Button("X") { dismiss()}.frame(alignment: .trailing)
            List {
                Section("Your actions for today") {
                }
                ForEach(selectActions.actions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) } , id: \.id) {
                    item in
                    ActionCompletionRowView(action: item, editable: true)
                }
                .onDelete(perform: selectActions.deleteAction)
                .onMove(perform: selectActions.move)
            }.listStyle(.plain)
        }
    }
}
