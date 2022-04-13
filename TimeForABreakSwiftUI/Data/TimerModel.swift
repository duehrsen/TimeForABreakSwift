//
//  tM.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-03-27.
//

import SwiftUI

class TimerModel : ObservableObject {
    
    @Published var to : CGFloat = 1
    @Published var isWorkTime : Bool = true
    @Published var unfocusDate : Date = Date()
    
    @Published var currentTimeRemaining : Int = 120    
    @Published var binaryDescendingTime : Int = 0
    @Published var started : Bool = false
    
    var workTimeTotalSeconds : Int = 60*20 {
        willSet {
            currentTimeRemaining = workTimeTotalSeconds
            started = false
        }
        didSet {
            objectWillChange.send()
        }
    }
    var breakTimeTotalSeconds : Int = 60*5 {
        willSet {
            currentTimeRemaining = breakTimeTotalSeconds
            started = false
        }
        didSet {
            objectWillChange.send()
        }
    }
    
    func movingToBackground(){
        if started
        {
            unfocusDate = Date()
            print("Current time remaining \(currentTimeRemaining)")
        }
    }
    
    func movingToActive()
    {
        if (!started)
        {
            currentTimeRemaining = isWorkTime ? workTimeTotalSeconds : breakTimeTotalSeconds
            return
        }
        let timeInterval: Int = Int(Date().timeIntervalSince(unfocusDate))
        let timeDiff : Int = currentTimeRemaining - timeInterval
        
        switch timeDiff {
        case Int.min...0:
            isWorkTime.toggle()
            currentTimeRemaining = isWorkTime ? workTimeTotalSeconds : breakTimeTotalSeconds
            started = false
        case 1...currentTimeRemaining:
            currentTimeRemaining = timeDiff
            started = true
        default:
            isWorkTime = true
            currentTimeRemaining = workTimeTotalSeconds
            started = false
        }
    }
    
    func resetTimer() {
        currentTimeRemaining = isWorkTime ? workTimeTotalSeconds : breakTimeTotalSeconds
        started = false
        to = 1
    }
                  
    
}
