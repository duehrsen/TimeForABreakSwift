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
        NavigationView {
            VStack{
//                HStack {
//                    Text("What you've been up to lately")
//                        .padding()
//                    Spacer()
//                }
                List {
                    Section("Completed Today") {
                    }
                    ForEach(selectActions.countedHistoryActions(actions: selectActions.actions
                        .filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) && $0.completed}), id: \.id) {
                        action in
                        HStack(spacing: 6) {
                            Text(action.title)
                                .font(.caption)
                                .badge("\(action.frequency)x")
                        }
                    }
                    Section("Completed Yesterday") {
                    }
                    ForEach(selectActions.countedHistoryActions(actions: selectActions.actions.filter{cal.isDateInYesterday($0.date ?? Date(timeInterval: -36000, since: Date())) && $0.completed}), id: \.id) {
                        item in
                        SimpleActionRowView(action: item)
                    }
                }.listStyle(.insetGrouped)
            }
            //.navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
               toolbars(title: "Summary")
            }
        }
        
    }
    
}
