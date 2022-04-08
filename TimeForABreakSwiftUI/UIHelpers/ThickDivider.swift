//
//  ThickDivider.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-05.
//

import SwiftUI

struct ThickDivider: View {
    let color: Color = .secondary
    let width: CGFloat = 2
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
    }
}
