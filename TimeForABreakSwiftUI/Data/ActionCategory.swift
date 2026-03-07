//
//  ActionCategory.swift
//  TimeForABreakSwiftUI
//

import Foundation

struct ActionCategory: Codable, Identifiable {
    var id: String                    // "exercise", "hydration", etc.
    var displayName: String           // "Exercise", "Stay Hydrated"
    var icon: String                  // SF Symbol name
    var minBreaksBetween: Int         // Don't repeat this category for N breaks
    var maxBreaksBetween: Int         // Must suggest this category within N breaks
    var dailyLimit: Int?              // Optional cap per day
}
