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
            Text("Action Summary")
            List {
                Section("Look at what you did yesterday") {
                }
                ForEach(selectActions.actions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) && $0.completed} , id: \.id) {
                    item in
                        ActionCompletionRowView(action: item, editable: false)
                }
            }.listStyle(.plain)
            
        }
       
    }
        
}
    

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
