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
            .padding(.vertical)
            .frame(width: (UIScreen.main.bounds.width / 2) - 55)
            .background(Color.blue)
            .clipShape(Capsule())
            .shadow(radius: 5)
            .lineSpacing(15)
        
    }
}
