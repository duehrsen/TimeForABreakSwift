//
//  CodableClosedRange.swift
//  TimeForABreakSwiftUI
//

import Foundation

/// A Codable wrapper around ClosedRange<Int> since ClosedRange does not
/// conform to Codable by default.
struct CodableClosedRange: Codable, Equatable {
    var lowerBound: Int
    var upperBound: Int

    var range: ClosedRange<Int> {
        lowerBound...upperBound
    }

    init(_ range: ClosedRange<Int>) {
        self.lowerBound = range.lowerBound
        self.upperBound = range.upperBound
    }

    init(lowerBound: Int, upperBound: Int) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }
}
