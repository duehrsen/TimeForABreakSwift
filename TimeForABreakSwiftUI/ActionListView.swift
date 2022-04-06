//
//  ActionListView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-28.
//

import SwiftUI
import Foundation

struct ActionListView: View {
    
    let defaultTime : Int = 3
    
    @EnvironmentObject var allActionsVM : ActionViewModel
    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @State private var actionString = ""
    @State private var durationValue = 3
    @State private var didLoadData = false
    
    let cal = Calendar.current
    
    
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
        NavigationView{
            VStack {
                // Area for selected actions
                List {
                    Section("Selected Actions") {
                        ForEach(selectActions.actions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) }, id: \.id) { action in
                            actionInfo(for: action)
                        }
                        .onDelete(perform: selectActions.deleteAction)
                        .onMove(perform: selectActions.move)
                    }
                }
                .frame(maxHeight: (UIScreen.main.bounds.height / 5))
                .listStyle(.plain)
                
                ThickDivider()
                
                // Input area for new actions
                HStack {
                    Spacer()
                    TextField("New action", text: $actionString)
                        .frame(width: 180, height: 45, alignment: .center)
                        .padding(.horizontal, 5)
                        .foregroundColor(Color.black)
                        .border(Color.blue)
                        .multilineTextAlignment(TextAlignment.center)
                    Stepper("\(durationValue) min", value: $durationValue, in: 1...10, step: 1) {_ in
                        
                    }
                    
                    Button(action: {
                        let actStr = actionString.trimmingCharacters(in: .whitespaces)
                        if (actStr.count > 0)
                        {
                            allActionsVM.add(action: actionString, duration: durationValue > 0 ? durationValue : defaultTime)
                            actionString = ""
                            durationValue = defaultTime
                        }
                        
                    }) {
                        Label("", systemImage: "plus.app.fill")
                            .foregroundColor(.blue)
                            .font(.largeTitle)
                    }
                }
                
                ThickDivider()
                
                
                // List area for all actions
                List {
                    Section("Available Actions") {
                        ForEach(allActionsVM.actions, id: \.id) { action in
                            NavigationLink(destination: ActionEditView(action: action)) {
                                HStack {
                                    Text(action.title)
                                        .font(.title2)
                                    Text(action.duration.formatted() + " min")
                                        .font(.subheadline)
                                        .frame(width: 40, alignment: .trailing)
                                        .background(Color.yellow)
                                }
                                
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                Button (action: { selectActions.add(action: action.title, duration: action.duration)}, label: {
                                    Label("Add", systemImage: "plus")
                                })
                                .tint(Color.yellow)
                            })
                        }
                    }
                    .onAppear() {
                        if !didLoadData
                        {
                            if allActionsVM.actions.count < 1 {
                                allActionsVM.getData()
                                didLoadData = true
                            }
                            
                        }
                        
                    }
                    
                }
                .listStyle(.plain)
                
            }
        }
        
    }
    
}
