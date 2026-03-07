//
//  BreakAction.swift
//  TimeForABreakStoryboard
//
//  Created by Chris Duehrsen on 2022-03-12.
//

import Foundation

struct BreakAction: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var spokenPrompt: String = ""
    var categoryId: String
    var duration: Int

    // Tracking
    var isQuantifiable: Bool = false
    var unit: String? = nil
    var defaultQuantity: Int? = nil

    // Voice recognition
    var triggerPhrases: [String] = []
    var suggestedPhrases: [String] = []

    // Scheduling
    var timesPerDay: Int? = nil
    var preferredTimeRange: CodableClosedRange? = nil

    // Metadata
    var isBuiltIn: Bool = false
    var pinned: Bool = false
    var completed: Bool = false
    var date: Date? = nil
    var linkurl: URL? = nil
    var frequency: Int = 1

    // MARK: - CodingKeys (handles legacy "desc" and "category" keys)

    enum CodingKeys: String, CodingKey {
        case id, title, description, spokenPrompt, categoryId, duration
        case isQuantifiable, unit, defaultQuantity
        case triggerPhrases, suggestedPhrases
        case timesPerDay, preferredTimeRange
        case isBuiltIn, pinned, completed, date, linkurl, frequency
        // Legacy keys for backward compatibility
        case desc, category
    }

    // MARK: - Backward-compatible decoding

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)

        // Try new key "description" first, fall back to legacy "desc"
        if let value = try container.decodeIfPresent(String.self, forKey: .description) {
            description = value
        } else {
            description = try container.decodeIfPresent(String.self, forKey: .desc) ?? ""
        }

        spokenPrompt = try container.decodeIfPresent(String.self, forKey: .spokenPrompt) ?? ""

        // Try new key "categoryId" first, fall back to legacy "category"
        if let value = try container.decodeIfPresent(String.self, forKey: .categoryId) {
            categoryId = value
        } else {
            categoryId = try container.decodeIfPresent(String.self, forKey: .category) ?? "mental"
        }

        duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 5
        isQuantifiable = try container.decodeIfPresent(Bool.self, forKey: .isQuantifiable) ?? false
        unit = try container.decodeIfPresent(String.self, forKey: .unit)
        defaultQuantity = try container.decodeIfPresent(Int.self, forKey: .defaultQuantity)
        triggerPhrases = try container.decodeIfPresent([String].self, forKey: .triggerPhrases) ?? []
        suggestedPhrases = try container.decodeIfPresent([String].self, forKey: .suggestedPhrases) ?? []
        timesPerDay = try container.decodeIfPresent(Int.self, forKey: .timesPerDay)
        preferredTimeRange = try container.decodeIfPresent(CodableClosedRange.self, forKey: .preferredTimeRange)
        isBuiltIn = try container.decodeIfPresent(Bool.self, forKey: .isBuiltIn) ?? false
        pinned = try container.decodeIfPresent(Bool.self, forKey: .pinned) ?? false
        completed = try container.decodeIfPresent(Bool.self, forKey: .completed) ?? false
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        linkurl = try container.decodeIfPresent(URL.self, forKey: .linkurl)
        frequency = try container.decodeIfPresent(Int.self, forKey: .frequency) ?? 1
    }

    // MARK: - Encoding (always uses new keys)

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(spokenPrompt, forKey: .spokenPrompt)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(duration, forKey: .duration)
        try container.encode(isQuantifiable, forKey: .isQuantifiable)
        try container.encodeIfPresent(unit, forKey: .unit)
        try container.encodeIfPresent(defaultQuantity, forKey: .defaultQuantity)
        try container.encode(triggerPhrases, forKey: .triggerPhrases)
        try container.encode(suggestedPhrases, forKey: .suggestedPhrases)
        try container.encodeIfPresent(timesPerDay, forKey: .timesPerDay)
        try container.encodeIfPresent(preferredTimeRange, forKey: .preferredTimeRange)
        try container.encode(isBuiltIn, forKey: .isBuiltIn)
        try container.encode(pinned, forKey: .pinned)
        try container.encode(completed, forKey: .completed)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(linkurl, forKey: .linkurl)
        try container.encode(frequency, forKey: .frequency)
    }

    // MARK: - Memberwise init

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        spokenPrompt: String = "",
        categoryId: String = "mental",
        duration: Int = 5,
        isQuantifiable: Bool = false,
        unit: String? = nil,
        defaultQuantity: Int? = nil,
        triggerPhrases: [String] = [],
        suggestedPhrases: [String] = [],
        timesPerDay: Int? = nil,
        preferredTimeRange: CodableClosedRange? = nil,
        isBuiltIn: Bool = false,
        pinned: Bool = false,
        completed: Bool = false,
        date: Date? = nil,
        linkurl: URL? = nil,
        frequency: Int = 1
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.spokenPrompt = spokenPrompt
        self.categoryId = categoryId
        self.duration = duration
        self.isQuantifiable = isQuantifiable
        self.unit = unit
        self.defaultQuantity = defaultQuantity
        self.triggerPhrases = triggerPhrases
        self.suggestedPhrases = suggestedPhrases
        self.timesPerDay = timesPerDay
        self.preferredTimeRange = preferredTimeRange
        self.isBuiltIn = isBuiltIn
        self.pinned = pinned
        self.completed = completed
        self.date = date
        self.linkurl = linkurl
        self.frequency = frequency
    }
}
