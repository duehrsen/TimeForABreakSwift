//
//  BoredResponse.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-11.
//

import Foundation

struct BoredResponse: Decodable {
    let activity : String
    let type : String
    let participants : Int
    let price : Double
    let link : String
    let key : String
    let accessibility : Double
}
