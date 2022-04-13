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
                    .font(.caption)
                Spacer()
                Label("", systemImage: action.pinned ? "pin.fill" : "pin.slash")
                    .font(.caption)
            }
        }
    }
    
    func togglePinned(action: BreakAction) {
        selectActions.pinToggle(action: action)
    }
    
    var body: some View {
        NavigationView{
            VStack {
                HStack {
                    Text("Select your actions for today")
                        .padding()
                    Spacer()
                }
                // Area for selected actions
                List {
                    Section("Selected") {
                        ForEach(selectActions.actions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) || $0.pinned }, id: \.id) { action in
                            actionInfo(for: action)
                        }
                        .onDelete(perform: selectActions.deleteAction)
                    }
                }
               // .frame(maxHeight: (UIScreen.main.bounds.height / 5))
                .listStyle(SidebarListStyle())
                                
                // List area for all actions
                List {
                    Section("Available") {
                        ForEach(allActionsVM.actions, id: \.id) { action in
                            NavigationLink(destination: ActionEditView(action: action)) {
                                Text(action.title)
                                    .font(.caption)
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
                                Button (role: .destructive, action: {
                                    allActionsVM.deleteById(id: action.id)}, label: {
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
                .listStyle(SidebarListStyle())
                Spacer()
                NavigationLink(destination: ActionCreateView()) {
                    HStack(spacing: 15){
                        Image(systemName: "plus.app.fill")
                            .foregroundColor(.white)
                        Text("Create New Action")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }.buttonStyle(FlatWideButtonStyle(bgColor: .green))
                Spacer()
                               
            }.navigationBarTitle("Break Actions") // end of vstack
        }
        
    }
}
