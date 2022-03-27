//
//  StandardButton.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-26.
//

import SwiftUI

struct StandardButton : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(Color.white)
            .padding()
            .background(Color.purple)
            .cornerRadius(20)
            .frame(minWidth: 150, idealWidth: 160, maxWidth: 250, minHeight: 40, idealHeight: 60, maxHeight: 80, alignment: .center)
        
    }
}
