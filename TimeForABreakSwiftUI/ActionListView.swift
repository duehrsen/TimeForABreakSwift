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
                        List (section.breakActions) { item in
                        HStack {
                            Text(item.title)
                                .font(.title2)
                            Text(item.duration.formatted() + " min")
                                .font(.subheadline)
                        }
                        .frame(height: 60)
                        }
                        .frame(height: 80*CGFloat(section.breakActions.count))
                        
                    }
            }
            .navigationTitle("Break Actions")
        }
    }
}
