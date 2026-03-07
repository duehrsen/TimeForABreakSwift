//
//  DataModelTests.swift
//  TimeForABreakSwiftUITests
//

import XCTest
@testable import Time_For_A_Break

final class DataModelTests: XCTestCase {

    // MARK: - BreakAction backward-compatible decoding

    func testDecodeOldFormatJSON() throws {
        let json = """
        {
            "id": "11111111-1111-1111-1111-111111111111",
            "title": "Test Action",
            "desc": "Old description field",
            "category": "relax",
            "duration": 5,
            "pinned": false,
            "completed": true,
            "frequency": 2
        }
        """.data(using: .utf8)!

        let action = try JSONDecoder().decode(BreakAction.self, from: json)
        XCTAssertEqual(action.title, "Test Action")
        XCTAssertEqual(action.description, "Old description field")
        XCTAssertEqual(action.categoryId, "relax")
        XCTAssertEqual(action.duration, 5)
        XCTAssertTrue(action.completed)
        XCTAssertEqual(action.frequency, 2)
    }

    func testDecodeNewFormatJSON() throws {
        let json = """
        {
            "id": "22222222-2222-2222-2222-222222222222",
            "title": "New Action",
            "description": "New description field",
            "categoryId": "exercise",
            "duration": 4,
            "isQuantifiable": true,
            "unit": "reps",
            "defaultQuantity": 10,
            "spokenPrompt": "Time to exercise!",
            "isBuiltIn": true,
            "pinned": false,
            "completed": false,
            "frequency": 1,
            "triggerPhrases": ["exercise"],
            "suggestedPhrases": ["exercise", "work out"]
        }
        """.data(using: .utf8)!

        let action = try JSONDecoder().decode(BreakAction.self, from: json)
        XCTAssertEqual(action.title, "New Action")
        XCTAssertEqual(action.description, "New description field")
        XCTAssertEqual(action.categoryId, "exercise")
        XCTAssertTrue(action.isQuantifiable)
        XCTAssertEqual(action.unit, "reps")
        XCTAssertEqual(action.defaultQuantity, 10)
        XCTAssertEqual(action.spokenPrompt, "Time to exercise!")
        XCTAssertTrue(action.isBuiltIn)
        XCTAssertEqual(action.triggerPhrases, ["exercise"])
        XCTAssertEqual(action.suggestedPhrases, ["exercise", "work out"])
    }

    func testEncodeUsesNewKeys() throws {
        let action = BreakAction(title: "Encode Test", description: "A description", categoryId: "mental", duration: 3)
        let data = try JSONEncoder().encode(action)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // New keys present
        XCTAssertNotNil(dict["description"])
        XCTAssertNotNil(dict["categoryId"])
        // Legacy keys absent
        XCTAssertNil(dict["desc"])
        XCTAssertNil(dict["category"])
    }

    func testNewFieldsDefaultWhenMissingFromJSON() throws {
        let json = """
        {
            "title": "Minimal",
            "desc": "Just basics",
            "category": "exercise",
            "duration": 2
        }
        """.data(using: .utf8)!

        let action = try JSONDecoder().decode(BreakAction.self, from: json)
        XCTAssertEqual(action.spokenPrompt, "")
        XCTAssertFalse(action.isQuantifiable)
        XCTAssertNil(action.unit)
        XCTAssertNil(action.defaultQuantity)
        XCTAssertEqual(action.triggerPhrases, [])
        XCTAssertEqual(action.suggestedPhrases, [])
        XCTAssertNil(action.timesPerDay)
        XCTAssertNil(action.preferredTimeRange)
        XCTAssertFalse(action.isBuiltIn)
        XCTAssertFalse(action.pinned)
        XCTAssertFalse(action.completed)
    }

    // MARK: - DataMigration

    func testMigrateCategoriesMapsOldToNew() {
        let actions = [
            BreakAction(title: "A", categoryId: "regular", duration: 1),
            BreakAction(title: "B", categoryId: "relax", duration: 1),
            BreakAction(title: "C", categoryId: "clean", duration: 1),
            BreakAction(title: "D", categoryId: "external", duration: 1),
            BreakAction(title: "E", categoryId: "exercise", duration: 1),
        ]

        let migrated = DataMigration.migrateCategories(in: actions)
        XCTAssertEqual(migrated[0].categoryId, "chores")    // regular → chores
        XCTAssertEqual(migrated[1].categoryId, "mental")     // relax → mental
        XCTAssertEqual(migrated[2].categoryId, "chores")     // clean → chores
        XCTAssertEqual(migrated[3].categoryId, "mental")     // external → mental
        XCTAssertEqual(migrated[4].categoryId, "exercise")   // exercise → exercise
    }

    func testMigrationPreservesNewCategoryIds() {
        let actions = [
            BreakAction(title: "A", categoryId: "hydration", duration: 1),
            BreakAction(title: "B", categoryId: "ergonomics", duration: 1),
            BreakAction(title: "C", categoryId: "mental", duration: 1),
        ]

        let migrated = DataMigration.migrateCategories(in: actions)
        XCTAssertEqual(migrated[0].categoryId, "hydration")
        XCTAssertEqual(migrated[1].categoryId, "ergonomics")
        XCTAssertEqual(migrated[2].categoryId, "mental")
    }

    // MARK: - CodableClosedRange

    func testCodableClosedRangeRoundTrip() throws {
        let original = CodableClosedRange(9...17)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CodableClosedRange.self, from: data)

        XCTAssertEqual(decoded.lowerBound, 9)
        XCTAssertEqual(decoded.upperBound, 17)
        XCTAssertEqual(decoded.range, 9...17)
        XCTAssertEqual(original, decoded)
    }

    // MARK: - ActionCategory

    func testActionCategoryRoundTrip() throws {
        let category = ActionCategory(id: "exercise", displayName: "Exercise", icon: "figure.walk", minBreaksBetween: 3, maxBreaksBetween: 8, dailyLimit: 5)
        let data = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(ActionCategory.self, from: data)

        XCTAssertEqual(decoded.id, "exercise")
        XCTAssertEqual(decoded.displayName, "Exercise")
        XCTAssertEqual(decoded.icon, "figure.walk")
        XCTAssertEqual(decoded.minBreaksBetween, 3)
        XCTAssertEqual(decoded.maxBreaksBetween, 8)
        XCTAssertEqual(decoded.dailyLimit, 5)
    }

    // MARK: - ActionCompletion

    func testActionCompletionRoundTrip() throws {
        let actionId = UUID()
        let completion = ActionCompletion(actionId: actionId, date: Date(), quantity: 20, source: .voice)
        let data = try JSONEncoder().encode(completion)
        let decoded = try JSONDecoder().decode(ActionCompletion.self, from: data)

        XCTAssertEqual(decoded.actionId, actionId)
        XCTAssertEqual(decoded.quantity, 20)
        XCTAssertEqual(decoded.source, .voice)
    }

    // MARK: - Preset data validation

    func testAllPresetActionsHaveValidCategoryId() {
        let categories = DataProvider.presetCategories()
        let categoryIds = Set(categories.map { $0.id })
        let actions = DataProvider.presetActions()

        for action in actions {
            XCTAssertTrue(categoryIds.contains(action.categoryId),
                          "\(action.title) has invalid categoryId: \(action.categoryId)")
        }
    }

    func testAllPresetActionsAreBuiltIn() {
        let actions = DataProvider.presetActions()
        for action in actions {
            XCTAssertTrue(action.isBuiltIn,
                          "\(action.title) should have isBuiltIn == true")
        }
    }
}
