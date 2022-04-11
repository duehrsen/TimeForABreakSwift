//
//  StandardButton.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-26.
//

import SwiftUI

struct FlatWideButtonStyle : ButtonStyle {
    
    var bgColor : Color
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration
            .label
            .foregroundColor(Color.white)
            .padding()
            .frame(width: (UIScreen.main.bounds.width), height: 60)
            .background(bgColor)
            .shadow(radius: 5)
            .lineSpacing(15)
        
    }
}
