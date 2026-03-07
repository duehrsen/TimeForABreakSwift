//
//  OptionsModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-15.
//

import Combine
import SwiftUI

struct OptionSet : Codable {
    var breaktimeMin : Int
    var worktimeMin : Int
    var doesPlaySounds : Bool
}

class OptionsModel: ObservableObject {

    static let defaultOptions = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false)

    private let persistence = PersistenceManager<OptionSet>(fileName: "options", defaultValue: OptionsModel.defaultOptions)

    @Published var options: OptionSet = defaultOptions

    func setDefault() {
        options = OptionsModel.defaultOptions
        saveToDisk()
    }

    func updateOptionsModel(breakMin: Int, workMin: Int, doesPlaySounds: Bool) {
        options.breaktimeMin = breakMin
        options.worktimeMin = workMin
        options.doesPlaySounds = doesPlaySounds
    }

    func save(options: OptionSet) async throws {
        try await persistence.save(data: options)
    }

    func load() async throws -> OptionSet {
        try await persistence.load()
    }

    func saveToDisk() {
        persistence.saveToDisk(data: options)
    }
}
