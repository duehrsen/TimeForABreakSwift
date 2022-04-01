//
//  ActionListView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-28.
//

import SwiftUI


struct ActionListView: View {
    
    @ObservedObject var actionVM : ActionViewModel = ActionViewModel()
    @State private var actionString = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Add breaktime action", text: $actionString)
                }
                .frame(width: 200, height: 45, alignment: .center)
                .padding(.horizontal, 40)
                .background(Color(.lightGray)
                    .cornerRadius(30))
                .foregroundColor(Color.white)
                
                Button(action: {
                    actionVM.add(action: actionString)
                    
                }) {
                    HStack(spacing: 15){
                        Text("Add Action")
                            .foregroundColor(.purple)
                    }
                    .padding(.vertical)
                    .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                    .background(
                        Capsule()
                            .stroke(Color.purple, lineWidth: 2)
                    )
                    .shadow(radius: 5)
                    
                }
                
                List {
                    ForEach(actionVM.actions, id: \.id) {
                    item in
                    HStack {
                        Text(item.title)
                            .font(.title2)
                        Text(item.duration.formatted() + " min")
                            .font(.subheadline)
                            .frame(width: 40, alignment: .trailing)
                            .background(Color.yellow)
                    }
                }
                    .onDelete(perform: actionVM.deleteAction)
            }
            
        }
        .navigationTitle("Break Actions")
        .onAppear() {
            actionVM.getData()
        }
    }
}
}
