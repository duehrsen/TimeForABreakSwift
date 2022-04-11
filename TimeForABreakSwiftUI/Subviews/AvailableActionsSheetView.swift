//
//  SelectedActionsSheetView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-10.
//

import SwiftUI

struct AvailableActionsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var selectActions : SelectedActionsViewModel
    @EnvironmentObject var allActionsVM : ActionViewModel
    
    let cal = Calendar.current
    
    @State private var actionString = ""
    @State private var durationValue = 3
    @State private var didLoadData = false
    
    let defaultTime : Int = 3
    
    var body: some View {
        
        
        // Input area for new actions
        VStack {
            Text("Create new action")
            HStack {
                Spacer()
                TextField("New action", text: $actionString)
                    .frame(height: 40, alignment: .center)
                    .padding(.horizontal, 5)
                    .foregroundColor(Color.black)
                    .background(Color.white)
                    .border(Color.secondary)
                    .multilineTextAlignment(TextAlignment.center)
                Spacer()
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
            Stepper("\(durationValue) min", value: $durationValue, in: 1...60, step: 1) {_ in
            }.frame(width: UIScreen.main.bounds.width - 60, alignment: .center)

        // End of VStack
        }
        .background(Color.secondary)
        
        // List area for all actions
        List {
            Section("Available Actions") {
                ForEach(allActionsVM.actions, id: \.id) { action in
                    NavigationLink(destination: ActionEditView(action: action)) {
                        Text(action.title)
                            .font(.body)
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
