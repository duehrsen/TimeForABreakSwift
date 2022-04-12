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
    var duration : Int
    var category : String
    var completed : Bool = false
    var date : Date?
    var linkurl : URL?
    var pinned: Bool = false
    var frequency: Int = 1
}
