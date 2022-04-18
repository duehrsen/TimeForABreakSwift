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
    
    private func onMove(source: IndexSet, destination: Int) {
        allActionsVM.actions.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        NavigationView{
            VStack {
                List {
                        ForEach(allActionsVM.actions, id: \.id) { action in
                            NavigationLink(destination: ActionEditView(action: action)) {
                                actionInfo(for: action)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                Button (action: {
                                    selectActions.add(action: action.title, duration: action.duration)
                                    showAddToast = true
                                }, label: {
                                    Label("Add to Selected Actions", systemImage: "plus.square.fill")
                                })
                                .tint(Color.blue)
                            })
                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                if !action.pinned{
                                    Button (action: {
                                        if allActionsVM.pinToggle(action: action, toggleOn: true) {               showPinToast = true
                                        }
                                    }, label: {
                                        Label("Pin to top of list", systemImage: "pin.fill")
                                    })
                                    .tint(Color.yellow)
                                }
                            })
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button (role: .destructive, action: {
                                    allActionsVM.deleteById(id: action.id)
                                    showDelToast = true
                                }, label: {
                                        Label("Remove from Available Actions", systemImage: "trash.fill")
                                    })
                            })
                            .swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                                if action.pinned {
                                    Button (action: {
                                        if allActionsVM.pinToggle(action: action, toggleOn: false) {               showUnpinToast = true
                                    }
                                    }, label: {
                                        Label("Unpin from top of list", systemImage: "pin.slash")
                                    })
                                    .tint(Color.yellow)
                                }

                            })
                        }
                        .onMove(perform: onMove)
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
                //.environment(\.editMode, .constant(.active))
                .listStyle(.plain)
                Spacer()
                NavigationLink(destination: ActionNewView()) {
                    HStack(spacing: 15){
                        Text("Create New Action")
                            .foregroundColor(.white)
                            //.font(.caption)
                    }
                }.buttonStyle(FlatWideButtonStyle(bgColor: .green))
                Spacer()
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
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
