//
//  ActionListView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-28.
//

import SwiftUI

struct ActionListView: View {
    
    let defaultTime : Int = 3
    
    @EnvironmentObject var allActionsVM : ActionViewModel
    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @State private var actionString = ""
    @State private var durationValue = 3
    @State private var didLoadData = false
    
    
    var defaultAction : BreakAction = BreakAction(title: "Get up!", desc: "Leave your chair", duration: 1, category: "relax")
    
    @ViewBuilder
    func actionInfo(for action: BreakAction) -> some View {
        HStack {
            Text(action.title)
                .font(.title2)
            Text(action.duration.formatted() + " min")
                .font(.subheadline)
                .frame(width: 40, alignment: .trailing)
                .background(Color.yellow)
        }
    }
    
    var body: some View {
        VStack {
            
            // Area for selected actions
            List {
                Section("Selected Actions") {
                    ForEach(selectActions.selectedActions , id: \.id) { action in
                        actionInfo(for: action)
                    }
                    .onDelete(perform: selectActions.deleteAction)
                    .onMove(perform: selectActions.move)
                }
            }
            
            // Input area for new actions
            HStack {
                TextField("New action", text: $actionString)
                    .frame(width: 100, height: 45, alignment: .center)
                    .padding(.horizontal, 40)
                    .foregroundColor(Color.black)
                Stepper("\(durationValue) min", value: $durationValue, in: 1...10, step: 1) {_ in
                    
                }
                
                Button(action: {
                    allActionsVM.add(action: actionString, duration: durationValue > 0 ? durationValue : defaultTime)
                    actionString = ""
                    durationValue = defaultTime
                    
                }) {
                    Label("", systemImage: "plus.app.fill")
                        .foregroundColor(.blue)
                        .font(.largeTitle)
                }
            }
            
            
            // List area for all actions
            List {
                Section("Available Actions") {
                    ForEach(allActionsVM.actions, id: \.id) { action in
                        HStack {
                            Text(action.title)
                                .font(.title2)
                            Text(action.duration.formatted() + " min")
                                .font(.subheadline)
                                .frame(width: 40, alignment: .trailing)
                                .background(Color.yellow)
                        }
                        
                        .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                            Button (action: { selectActions.add(action: action)}, label: {
                                Label("Add", systemImage: "plus")
                            })
                            .tint(Color.yellow)
                            
                        })
                        
                    }
                }
                .onAppear() {
                    if !didLoadData
                    {
                        allActionsVM.getData()
                        didLoadData = true
                    }
                    
                }
                
            }
            
            
        }
    }
    
}
