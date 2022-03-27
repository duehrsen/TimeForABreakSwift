//
//  TimerModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-27.
//

import SwiftUI

class TimerModel : ObservableObject {
    @Published var workTimeTotalSeconds : Int = 2334
    @Published var breakTimeTotalSeconds : Int = 300
    @Published var currentTimeRemaining : Int = 1800
    
    @Published var binaryDescendingTime : Int = 0
    
}
