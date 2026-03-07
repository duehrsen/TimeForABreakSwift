//
//  ActionCompletion.swift
//  TimeForABreakSwiftUI
//

import Foundation

enum CompletionSource: String, Codable {
    case voice
    case manual
}

struct ActionCompletion: Codable, Identifiable {
    var id: UUID = UUID()
    var actionId: UUID
    var date: Date
    var quantity: Int?
    var source: CompletionSource
}
