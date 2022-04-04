//
//  tM.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-27.
//

import SwiftUI

class TimerModel : ObservableObject {
    var workTimeTotalSeconds : Int = 120 {
        willSet {
            currentTimeRemaining = workTimeTotalSeconds
            started = false
        }
        didSet {
            objectWillChange.send()
        }
    }
    var breakTimeTotalSeconds : Int = 60 {
        willSet {
            currentTimeRemaining = breakTimeTotalSeconds
            started = false
        }
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var currentTimeRemaining : Int = 120
    
    @Published var binaryDescendingTime : Int = 0
    @Published var started : Bool = false
    
}
