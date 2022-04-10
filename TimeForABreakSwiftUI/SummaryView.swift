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
        VStack{
            Text("What you've been up to lately")
            List {
                Section("Today") {
                }
                ForEach(selectActions.actions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date()))} , id: \.id) {
                    item in
                        SimpleActionRowView(action: item)
                }
                Section("Yesterday") {
                }
                ForEach(selectActions.actions.filter{cal.isDateInYesterday($0.date ?? Date(timeInterval: -36000, since: Date()))} , id: \.id) {
                    item in
                        SimpleActionRowView(action: item)
                }
            }.listStyle(.insetGrouped)
        }
       
    }
        
}
    

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
