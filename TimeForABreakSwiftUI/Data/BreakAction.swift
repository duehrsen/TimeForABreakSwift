//
//  BreakAction.swift
//  TimeForABreakStoryboard
//
//  Created by Chris Duehrsen on 2022-03-12.
//

import SwiftUI

struct BreakAction : Codable, Identifiable {
    var id = UUID()
    var title : String
    var desc : String
    var duration : Int8
    var category : String
    var linkurl : URL?
}

struct BreakActionSection : Identifiable {
    var id = UUID()
    var categoryName : String
    var breakActions : [BreakAction]
}
