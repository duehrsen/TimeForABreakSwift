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
        Button {
            togglePinned(action: action)
        } label: {
            HStack {
                Text(action.title)
                    .font(.title2)
                Spacer()
                Label("", systemImage: action.pinned ? "pin.fill" : "pin.slash")
            }
        }
    }
    
    func togglePinned(action: BreakAction) {
        selectActions.pinToggle(action: action)
    }
    
    var body: some View {
        NavigationView{
            VStack {
                // Area for selected actions
                List {
                    Section("Selected Actions") {
                        ForEach(selectActions.actions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) || $0.pinned }, id: \.id) { action in
                            actionInfo(for: action)
                        }
                        .onDelete(perform: selectActions.deleteAction)
                    }
                }
                .frame(maxHeight: (UIScreen.main.bounds.height / 5))
                .listStyle(.plain)
                
                // Input area for new actions
                HStack {
                    Spacer()
                    TextField("New action", text: $actionString)
                        .frame(width: (UIScreen.main.bounds.width/3), height: 45, alignment: .center)
                        .padding(.horizontal, 5)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                        .border(Color.secondary)
                        .multilineTextAlignment(TextAlignment.center)
                    Stepper("\(durationValue) min", value: $durationValue, in: 1...60, step: 1) {_ in
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
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    }
                }
                .background(Color.secondary)
                
                // List area for all actions
                List {
                    Section("Available Actions") {
                        ForEach(allActionsVM.actions, id: \.id) { action in
                            NavigationLink(destination: ActionEditView(action: action)) {
                                Text(action.title)
                                    .font(.title2)
                                    .badge(action.duration < 30 ? action.duration.formatted() + " min" : "a while")
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                Button (action: { selectActions.add(action: action.title, duration: action.duration)}, label: {
                                    Text("Add to Selected Actions")
                                    //Label("Add to Selected Actions", systemImage: "plus.square.fill")
                                })
                                .tint(Color.green)
                            })
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button (role: .destructive, action: { selectActions.add(action: action.title, duration: action.duration)}, label: {
                                    Text("Remove from Available Actions")
                                    //Label("Remove from Available Actions", systemImage: "trash.fill")
                                })
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
