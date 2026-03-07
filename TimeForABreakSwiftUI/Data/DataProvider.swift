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
        
        data.append(BreakAction(title: "Water plants", description: "Add some water or food to house plants", categoryId: "regular", duration: 4))
        data.append(
        BreakAction(title: "Prepare the trash", description: "Bundle up the garbage", categoryId: "regular", duration: 5))
        data.append(
        BreakAction(title: "Take out the trash", description: "Take out the trash", categoryId: "regular", duration: 5))
        data.append(
        BreakAction(title: "Check the mail", description: "Retrieve the mail and put important mail in an easy to find location", categoryId: "regular", duration: 5))
        data.append(
        BreakAction(title: "Look into distance", description: "Look at an an object at least 50 m away for 20 seconds", categoryId: "relax", duration: 2))
        data.append(
        BreakAction(title: "Take a walk", description: "Walk outside your computer area", categoryId: "relax", duration: 3))
        data.append(
        BreakAction(title: "Drink some water", description: "Drink water or some other beverage", categoryId: "relax", duration: 3))
        
        data.append(
        BreakAction(title: "Load / Unload dishes", description: "Put dishes into or out of dishwasher", categoryId: "clean", duration: 7))
        data.append(
        BreakAction(title: "Wipe a surface", description: "Wipe down a surface to clean it", categoryId: "clean", duration: 2, linkurl: URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/prevent-getting-sick/disinfecting-your-home.html")))
        data.append(
        BreakAction(title: "Vacuum", description: "Run the vacuum cleaner over one section of your home", categoryId: "clean", duration: 5))
        data.append(
        BreakAction(title: "Tidy up one area", description: "Take objects from one section of your home and put them into their appropriate storage location", categoryId: "clean", duration: 4))
        data.append(
        BreakAction(title: "Make the bed", description: "", categoryId: "clean", duration: 5))
        data.append(
        BreakAction(title: "Pay bills", description: "", categoryId: "regular", duration: 5))
        data.append(
        BreakAction(title: "Do a milk run", description: "", categoryId: "regular", duration: 15))

        
    
        data.append(
        BreakAction(title: "Exercise: Do a few pushups", description: "Laying on your belly with your hands on the ground by your shoulders, push up with your arms until extended. Do a set that tires you", categoryId: "exercise", duration: 4))
        data.append(BreakAction(title: "Exercise: Back Bridges", description: "Lie on your back with your knees bent. Tighten your abdominal muscles. Raise your hips off the floor until your hips are aligned with your knees and shoulders. Hold for three deep breaths. Return to the starting position and repeat.", categoryId: "exercise", duration: 4, linkurl: URL(string: "https://www.mayoclinic.org/healthy-lifestyle/labor-and-delivery/multimedia/bridge-exercise/img-20006409")))
        
        return data
    }
    
}
