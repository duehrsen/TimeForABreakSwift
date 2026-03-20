//
//  PersistenceManagerTests.swift
//  TimeForABreakSwiftUITests
//
//  Created on 2026-03-03.
//

import XCTest
@testable import Time_For_A_Break

final class PersistenceManagerTests: XCTestCase {

    private var testFileName: String!

    override func setUp() {
        super.setUp()
        testFileName = "test_\(UUID().uuidString)"
    }

    override func tearDown() {
        if let url = try? FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: false
        ).appendingPathComponent("\(testFileName!).data") {
            try? FileManager.default.removeItem(at: url)
        }
        super.tearDown()
    }

    // MARK: - Load Default

    func testLoadReturnsDefaultWhenFileDoesNotExist() async throws {
        let sut = PersistenceManager<[BreakAction]>(fileName: testFileName, defaultValue: [])
        let items = try await sut.load()
        XCTAssertEqual(items.count, 0)
    }

    func testLoadReturnsDefaultOptionSet() async throws {
        let defaultOptions = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false)
        let sut = PersistenceManager<OptionSet>(fileName: testFileName, defaultValue: defaultOptions)
        let options = try await sut.load()
        XCTAssertEqual(options.breaktimeMin, 5)
        XCTAssertEqual(options.worktimeMin, 20)
        XCTAssertEqual(options.completionFeedback, .none)
    }

    // MARK: - Save and Load Round Trip

    func testSaveAndLoadRoundTrip() async throws {
        let sut = PersistenceManager<[BreakAction]>(fileName: testFileName, defaultValue: [])
        let actions = [BreakAction(title: "Test Action", description: "Description", categoryId: "test", duration: 5)]

        try await sut.save(data: actions)
        let loaded = try await sut.load()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "Test Action")
        XCTAssertEqual(loaded.first?.duration, 5)
    }

    // MARK: - Overwrite

    func testSaveOverwritesPreviousData() async throws {
        let sut = PersistenceManager<[BreakAction]>(fileName: testFileName, defaultValue: [])
        let first = [BreakAction(title: "First", description: "", categoryId: "test", duration: 1)]
        let second = [BreakAction(title: "Second", description: "", categoryId: "test", duration: 2)]

        try await sut.save(data: first)
        try await sut.save(data: second)
        let loaded = try await sut.load()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "Second")
    }

    // MARK: - OptionSet Round Trip

    func testOptionSetSaveAndLoadRoundTrip() async throws {
        let defaultOptions = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false)
        let sut = PersistenceManager<OptionSet>(fileName: testFileName, defaultValue: defaultOptions)
        let customOptions = OptionSet(breaktimeMin: 10, worktimeMin: 30, doesPlaySounds: true)

        try await sut.save(data: customOptions)
        let loaded = try await sut.load()

        XCTAssertEqual(loaded.breaktimeMin, 10)
        XCTAssertEqual(loaded.worktimeMin, 30)
        XCTAssertEqual(loaded.completionFeedback, .sound)
    }

    func testOptionSetCompletionFeedbackAndVoiceRoundTrip() async throws {
        let defaultOptions = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false)
        let sut = PersistenceManager<OptionSet>(fileName: testFileName, defaultValue: defaultOptions)
        var custom = OptionSet(breaktimeMin: 7, worktimeMin: 22, completionFeedback: .haptic, speakBreakSuggestions: false)

        try await sut.save(data: custom)
        let loaded = try await sut.load()

        XCTAssertEqual(loaded.completionFeedback, .haptic)
        XCTAssertFalse(loaded.speakBreakSuggestions)
    }

    func testOptionSetMigratesLegacyMutedWithoutNewKeys() throws {
        let json = """
        {"breaktimeMin":5,"worktimeMin":20,"doesPlaySounds":false,"isMuted":true}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(OptionSet.self, from: json)
        XCTAssertEqual(decoded.completionFeedback, .none)
        XCTAssertFalse(decoded.speakBreakSuggestions)
    }

    func testOptionSetMigratesLegacyUnmutedWithoutCompletionKey() throws {
        let json = """
        {"breaktimeMin":5,"worktimeMin":20,"doesPlaySounds":true,"isMuted":false}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(OptionSet.self, from: json)
        XCTAssertEqual(decoded.completionFeedback, .sound)
        XCTAssertTrue(decoded.speakBreakSuggestions)
    }
}
