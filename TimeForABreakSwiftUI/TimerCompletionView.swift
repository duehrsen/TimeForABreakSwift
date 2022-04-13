//
//  TimerCompletionView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-12.
//

import SwiftUI

struct TimerCompletionView: View {
    
    @EnvironmentObject var selectActions : SelectedActionsViewModel
    
    var isFinishedWork : Bool
    let cal = Calendar.current
    
    @EnvironmentObject var tm : TimerModel
    var body: some View {
        VStack(spacing: 60) {
            Spacer()
            Text(isFinishedWork ? "Awesome work! \nTime for a break, eh?" : "Break time's up! \nHope you are refreshed and recharged")
                .font(.title)
                .lineLimit(4)
                .minimumScaleFactor(0.5)
                .foregroundColor(Color.blue)
                .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
            Image(systemName: isFinishedWork ? "hands.sparkles.fill" : "bolt.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.yellow)
                .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
                .onAppear(perform: {
                    tm.isWorkTime.toggle()
                    tm.resetTimer()
                })
            if isFinishedWork {
                List {
                    Section("Some actions left to do" ) {
                    }
                    ForEach(
                        selectActions.actions.filter{
                            
                            ( cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) || $0.pinned) && $0.completed == false
                            
                        } , id: \.id) {
                            item in
                            SimpleActionRowView(action: item)
                        }
                }.listStyle(.plain)
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
            } else {
                SelectedActionsSheetView(isFromCompletedSheet: true)
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

