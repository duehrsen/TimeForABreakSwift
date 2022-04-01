//
//  ActionListView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-28.
//

import SwiftUI

class ActionViewModel: ObservableObject {
    @Published var sections : [BreakActionSection] = []
    
    func getData() {
        sections = DataProvider.mockData()
    }
    
    func deleteAction(index: IndexSet) {
        sections.remove(atOffsets: index)
    }
    
    func add(action: String) {
        print("in it with string \(action)")
        if var section = sections.first(where: {$0.categoryName.contains("Regular") }) {
            let newAction = BreakAction(title: action, desc: action, duration: 3, category: "regular")
            section.breakActions.append(newAction)
        }
    }
    
}

struct ActionListView: View {
    
    @ObservedObject var actionVM : ActionViewModel = ActionViewModel()
    @State private var actionString = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Add breaktime action", text: $actionString)
                    Image(systemName: "mic.fill")
                }
                .frame(width: 200, height: 45, alignment: .center)
                .padding(.horizontal, 40)
                .background(Color(.systemGray)
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
                
                List(actionVM.sections, id: \.id) { section in
                    Section(header: Text(section.categoryName))
                        {
                            ForEach(section.breakActions) {
                                item in
                                HStack {
                                    Text(item.title)
                                        .font(.title2)
                                    Text(item.duration.formatted() + " min")
                                        .font(.subheadline)
                                        .frame(width: 40, alignment: .trailing)
                                        .background(Color.yellow)
                                }
//                                .swipeActions(edge: .trailing, allowsFullSwipe: false)
//                                {
//                                    Button(role: .destructive) {
//
//                                    } label: {
//                                        Label("Archive", systemImage: "trash.fill")
//                                    }
//
//                                }
//                                .swipeActions(edge: .leading, allowsFullSwipe: false)
//                                {
//                                    Button() {
//                                        print("Pinning item")
//                                    } label: {
//                                        Label("Pin", systemImage: "pin.fill")
//                                    }
//                                    .tint(Color.yellow)
//                                }
                                
                        }
                            //.onDelete(perform: actionVM.deleteAction)
                            
                }
                
            }
                .navigationTitle("Break Actions")
                .onAppear() {
                    actionVM.getData()
                }
            }
    }
}
}
