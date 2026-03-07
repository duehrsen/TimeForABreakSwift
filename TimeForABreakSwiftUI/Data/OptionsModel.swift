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
    var isMuted : Bool = false

    init(breaktimeMin: Int, worktimeMin: Int, doesPlaySounds: Bool, isMuted: Bool = false) {
        self.breaktimeMin = breaktimeMin
        self.worktimeMin = worktimeMin
        self.doesPlaySounds = doesPlaySounds
        self.isMuted = isMuted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        breaktimeMin = try container.decode(Int.self, forKey: .breaktimeMin)
        worktimeMin = try container.decode(Int.self, forKey: .worktimeMin)
        doesPlaySounds = try container.decodeIfPresent(Bool.self, forKey: .doesPlaySounds) ?? false
        if let saved = try container.decodeIfPresent(Bool.self, forKey: .isMuted) {
            isMuted = saved
        } else {
            // Migrate: derive from existing doesPlaySounds preference
            isMuted = !doesPlaySounds
        }
    }
}

class OptionsModel: ObservableObject {

    static let defaultOptions = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false, isMuted: false)

    private let persistence = PersistenceManager<OptionSet>(fileName: "options", defaultValue: OptionsModel.defaultOptions)

    @Published var options: OptionSet = defaultOptions

    func setDefault() {
        options = OptionsModel.defaultOptions
        saveToDisk()
    }

    func updateOptionsModel(breakMin: Int, workMin: Int, doesPlaySounds: Bool, isMuted: Bool) {
        options.breaktimeMin = breakMin
        options.worktimeMin = workMin
        options.doesPlaySounds = doesPlaySounds
        options.isMuted = isMuted
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
