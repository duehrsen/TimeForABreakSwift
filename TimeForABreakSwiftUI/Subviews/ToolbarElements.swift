//
//  ToolbarElements.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import SwiftUI

@ToolbarContentBuilder
func toolbars(title: String, skipOptions: Bool = false) -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
        TimeRemainingSubView()
    }
    ToolbarItem(placement: .navigationBarLeading) {
        Text(title)
            .font(.system(size:24))
    }
}
