//
//  OptionsModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-15.
//

import Combine
import SwiftUI

/// Serializable user preference set controlling timer durations and audio behavior.
struct OptionSet: Codable {
    var breaktimeMin: Int
    var worktimeMin: Int
    var doesPlaySounds: Bool
    var isMuted: Bool = false

    /// Optional titles for the daily suggested actions set.
    /// If nil or empty, `DataProvider.defaultDailySuggestedActionTitles()` is used.
    var dailySuggestedTitles: [String]? = nil

    /// Number of action ring segments (daily goal). 5...10. Applies from the next day.
    var dailyActionGoal: Int = 5

    init(
        breaktimeMin: Int,
        worktimeMin: Int,
        doesPlaySounds: Bool,
        isMuted: Bool = false,
        dailySuggestedTitles: [String]? = nil,
        dailyActionGoal: Int = 5
    ) {
        self.breaktimeMin = breaktimeMin
        self.worktimeMin = worktimeMin
        self.doesPlaySounds = doesPlaySounds
        self.isMuted = isMuted
        self.dailySuggestedTitles = dailySuggestedTitles
        self.dailyActionGoal = min(10, max(5, dailyActionGoal))
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
        dailySuggestedTitles = try container.decodeIfPresent([String].self, forKey: .dailySuggestedTitles)
        let raw = try container.decodeIfPresent(Int.self, forKey: .dailyActionGoal) ?? 5
        dailyActionGoal = min(10, max(5, raw))
    }
}

/// Observable wrapper around `OptionSet` with disk persistence and helper logic
/// (for example the effective action ring segment count for the current day).
class OptionsModel: ObservableObject {

    static let defaultOptions = OptionSet(
        breaktimeMin: 5,
        worktimeMin: 20,
        doesPlaySounds: false,
        isMuted: false,
        dailySuggestedTitles: DataProvider.defaultDailySuggestedActionTitles()
    )

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

    // MARK: - Action ring segment count (effective for “today”; new goal applies next day)

    private static let actionRingEffectiveDayKey = "actionRingEffectiveDay"
    private static let actionRingSegmentCountKey = "actionRingSegmentCount"

    /// Segment count to show in the action ring today. Updated only when the calendar day changes.
    func effectiveSegmentCountForToday(calendar: Calendar = .current) -> Int {
        let today = calendar.startOfDay(for: Date())
        let defaults = UserDefaults.standard
        let storedDay = defaults.object(forKey: Self.actionRingEffectiveDayKey) as? Date
        let storedCount = defaults.integer(forKey: Self.actionRingSegmentCountKey)
        if storedCount > 0, let d = storedDay, calendar.isDate(d, inSameDayAs: today) {
            return storedCount
        }
        let count = min(10, max(5, options.dailyActionGoal))
        defaults.set(today, forKey: Self.actionRingEffectiveDayKey)
        defaults.set(count, forKey: Self.actionRingSegmentCountKey)
        return count
    }
}
