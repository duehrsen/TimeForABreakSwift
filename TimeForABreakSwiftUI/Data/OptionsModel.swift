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

    func save(options: OptionSet, completion: @escaping (Result<Int, Error>) -> Void) {
        persistence.save(data: options, completion: completion)
    }

    func load(completion: @escaping (Result<OptionSet, Error>) -> Void) {
        persistence.load(completion: completion)
    }

    func saveToDisk() {
        persistence.saveToDisk(data: options)
    }
}
