//
//  ActionListView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-28.
//

import SwiftUI
import Foundation

struct ActionListView: View {
    
    let attributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24),
        NSAttributedString.Key.foregroundColor: UIColor.systemBlue
    ]
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    let defaultTime : Int = 3
    
    @EnvironmentObject var allActionsVM : ActionViewModel
    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @State private var actionString = ""
    @State private var durationValue = 3
    @State private var didLoadData = false
    
    // Toast vars
    @State private var showAddToast = false
    @State private var showDelToast = false
    @State private var showPinToast = false
    @State private var showUnpinToast = false
    
    
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
                Label("", systemImage: action.pinned ? "pin.fill" : "")
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
//                HStack {
//                    Text("Select your actions for today")
//                        .padding()
//                    Spacer()
//                }
                // Area for selected actions
//                List {
//                    Section("Selected") {
//                        ForEach(selectActions.actions.filter{cal.isDateInToday($0.date ?? Date(timeInterval: -36000, since: Date())) || $0.pinned }, id: \.id) { action in
//                            actionInfo(for: action)
//                        }
//                        .onDelete(perform: selectActions.deleteAction)
//                    }
//                }
//                // .frame(maxHeight: (UIScreen.main.bounds.height / 5))
//                .listStyle(SidebarListStyle())
                
                // List area for all actions
                List {
                    Section("Available") {
                        ForEach(allActionsVM.actions, id: \.id) { action in
                            NavigationLink(destination: ActionEditView(action: action)) {
                                actionInfo(for: action)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                Button (action: {
                                    selectActions.add(action: action.title, duration: action.duration)
                                    showAddToast = true
                                }, label: {
                                    //Text("Add to Selected Actions")
                                    Label("Add to Selected Actions", systemImage: "plus.square.fill")
                                })
                                .tint(Color.blue)
                            })
                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                Button (action: {
                                    
                                    if allActionsVM.pinToggle(action: action, toggleOn: true) {               showPinToast = true
                                    }
                                    
                                }, label: {
                                    //Text("Pin to top of list")
                                    Label("Pin to top of list", systemImage: "pin.fill")
                                })
                                .tint(Color.yellow)
                            })
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button (role: .destructive, action: {
                                    allActionsVM.deleteById(id: action.id)
                                    showDelToast = true
                                }, label: {
                                        //Text("Remove from Available Actions")
                                        Label("Remove from Available Actions", systemImage: "trash.fill")
                                    })
                            })
                            .swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                                Button (action: {
                                    if allActionsVM.pinToggle(action: action, toggleOn: false) {               showUnpinToast = true
                                }
                                }, label: {
                                    //Text("Unpin from top of list")
                                    Label("Unpin from top of list", systemImage: "pin.slash")
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
                Spacer()
                NavigationLink(destination: ActionNewView()) {
                    HStack(spacing: 15){
                        //Image(systemName: "plus.app.fill").foregroundColor(.white)
                        Text("Create New Action")
                            .foregroundColor(.white)
                            //.font(.caption)
                    }
                }.buttonStyle(FlatWideButtonStyle(bgColor: .green))
                Spacer()
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbars(title: "Actions")                
            }
            .toast(message: "Added to today's list",
                   isShowing: $showAddToast,
                   config: .init(backgroundColor: .blue.opacity(0.8),
                                sysImg: "plus.circle.fill")
            )
            .toast(message: "Removed action",
                   isShowing: $showDelToast,
                   config: .init(backgroundColor: .red.opacity(0.8),
                                 sysImg: "trash.fill")
            )
            .toast(message: "Pinned action to top",
                   isShowing: $showPinToast,
                   config: .init(backgroundColor: .yellow.opacity(0.8),
                                 sysImg: "pin.fill")
            )
            .toast(message: "Unpinned action",
                   isShowing: $showUnpinToast,
                   config: .init(backgroundColor: .yellow.opacity(0.8),
                                 sysImg: "pin.slash")
            )
            
        }
        
    }
}
