//
//  ActionListView.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-28.
//

import SwiftUI

struct ActionListView: View {
    var sections : [BreakActionSection] = DataProvider.mockData()
    
    var body: some View {
        NavigationView {
            List(sections, id: \.id) { section in
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: false)
                            {
                                Button(role: .destructive) {
                                    print("Archiving item")
                                } label: {
                                    Label("Archive", systemImage: "trash.fill")
                                }

                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false)
                            {
                                Button() {
                                    print("Pinning item")
                                } label: {
                                    Label("Pin", systemImage: "pin.fill")
                                }
                                .tint(Color.yellow)
                            }
                    }
            }
            
        }
            .navigationTitle("Break Actions")
    }
}
}
