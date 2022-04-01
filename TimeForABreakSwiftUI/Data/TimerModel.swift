//
//  TimerModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-27.
//

import SwiftUI

class TimerModel : ObservableObject {
    @Published var workTimeTotalSeconds : Int = 120
    @Published var breakTimeTotalSeconds : Int = 60
    @Published var currentTimeRemaining : Int = 120
    
    @Published var binaryDescendingTime : Int = 0
    
}
