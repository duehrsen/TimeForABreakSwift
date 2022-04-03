//
//  ActionListView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-28.
//

import SwiftUI


struct ActionListView: View {
    
    @EnvironmentObject var allActionsVM : ActionViewModel
    @EnvironmentObject var selectActions: SelectedActionsViewModel
    @State private var actionString = ""
    @State private var durationValue = 5
    
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
                Text("Selected Actions")
                    .font(.subheadline)
                List {
                    ForEach(selectActions.selectedActions , id: \.id) { action in
                        actionInfo(for: action)
                    }
                    .onDelete(perform: selectActions.deleteAction)
                    .onMove(perform: selectActions.move)
                }
                TextField("Add breaktime action", text: $actionString)
                        .frame(width: 200, height: 45, alignment: .center)
                        .padding(.horizontal, 40)
                        .foregroundColor(Color.black)
//                Picker("", selection: $durationValue){
//                    ForEach(1...10, id:\.self) {
//                        Text("\($0)")
//                            .font(.subheadline)
//                    }
//                }
                
                Button(action: {
                    allActionsVM.add(action: actionString)
                }) {
                    HStack(spacing: 15){
                        Text("Add Action")
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical)
                    .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                    .background(
                        Capsule()
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .shadow(radius: 5)
                    
                }
                
                List {
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
                    allActionsVM.getData()

        }
               

        }
    }

}
