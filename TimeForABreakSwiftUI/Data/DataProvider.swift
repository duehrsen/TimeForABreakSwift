//
//  DataProvider.swift
//  TimeForABreakStoryboard
//
//  Created by Chris Duehrsen on 2022-03-12.
//

import UIKit

class DataProvider {
    static var data : [BreakAction] = []
    
    static func mockData() -> [BreakAction] {
        
        data.append(BreakAction(title: "Water plants", desc: "Add some water or food to house plants", duration: 4, category: "regular"))
        data.append(
        BreakAction(title: "Prepare the trash", desc: "Bundle up the garbage", duration: 5, category: "regular"))
        data.append(
        BreakAction(title: "Take out the trash", desc: "Take out the trash", duration: 5, category: "regular"))
        data.append(
        BreakAction(title: "Check the mail", desc: "Retrieve the mail and put important mail in an easy to find location", duration: 5, category: "regular"))
        data.append(
        BreakAction(title: "Look into distance", desc: "Look at an an object at least 50 m away for 20 seconds", duration: 2, category: "relax"))
        data.append(
        BreakAction(title: "Take a walk", desc: "Walk outside your computer area", duration: 3, category: "relax"))
        data.append(
        BreakAction(title: "Drink some water", desc: "Drink water or some other beverage", duration: 3, category: "relax"))
        
        data.append(
        BreakAction(title: "Load / Unload dishes", desc: "Put dishes into or out of dishwasher", duration: 7, category: "clean"))
        data.append(
        BreakAction(title: "Wipe a surface", desc: "Wipe down a surface to clean it", duration: 2, category: "clean", linkurl: URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/prevent-getting-sick/disinfecting-your-home.html")))
        data.append(
        BreakAction(title: "Vacuum", desc: "Run the vacuum cleaner over one section of your home", duration: 5, category: "clean"))
        data.append(
        BreakAction(title: "Tidy up one area", desc: "Take objects from one section of your home and put them into their appropriate storage location", duration: 4, category: "clean"))
        data.append(
        BreakAction(title: "Make the bed", desc: "", duration: 5, category: "clean"))
        data.append(
        BreakAction(title: "Pay bills", desc: "", duration: 5, category: "regular"))
        data.append(
        BreakAction(title: "Do a milk run", desc: "", duration: 15, category: "regular"))

        
    
        data.append(
        BreakAction(title: "Exercise: Do a few pushups", desc: "Laying on your belly with your hands on the ground by your shoulders, push up with your arms until extended. Do a set that tires you", duration: 4, category: "exercise"))
        data.append(BreakAction(title: "Exercise: Back Bridges", desc: "Lie on your back with your knees bent. Tighten your abdominal muscles. Raise your hips off the floor until your hips are aligned with your knees and shoulders. Hold for three deep breaths. Return to the starting position and repeat.", duration: 4, category: "exercise", linkurl: URL(string: "https://www.mayoclinic.org/healthy-lifestyle/labor-and-delivery/multimedia/bridge-exercise/img-20006409")))
        
        data.map { breakAction in
            print( breakAction.title)
        }
        
        return data
    }
    
}
