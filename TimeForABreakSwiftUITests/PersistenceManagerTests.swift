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

    func testLoadReturnsDefaultWhenFileDoesNotExist() {
        let sut = PersistenceManager<[BreakAction]>(fileName: testFileName, defaultValue: [])
        let expectation = expectation(description: "load completes")

        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items.count, 0)
            case .failure:
                XCTFail("Should not fail when file does not exist")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testLoadReturnsDefaultOptionSet() {
        let defaultOptions = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false)
        let sut = PersistenceManager<OptionSet>(fileName: testFileName, defaultValue: defaultOptions)
        let expectation = expectation(description: "load completes")

        sut.load { result in
            switch result {
            case .success(let options):
                XCTAssertEqual(options.breaktimeMin, 5)
                XCTAssertEqual(options.worktimeMin, 20)
                XCTAssertFalse(options.doesPlaySounds)
            case .failure:
                XCTFail("Should not fail when file does not exist")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - Save and Load Round Trip

    /// Helper: synchronously saves data using the manager's background queue
    private func saveAndWait<U: Codable>(_ manager: PersistenceManager<U>, data: U) {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .background).async {
            // Write synchronously on this background queue
            manager.saveToDisk(data: data)
            // Give the nested background dispatch time to complete
            Thread.sleep(forTimeInterval: 0.5)
            semaphore.signal()
        }
        semaphore.wait()
    }

    func testSaveAndLoadRoundTrip() {
        let sut = PersistenceManager<[BreakAction]>(fileName: testFileName, defaultValue: [])
        let actions = [BreakAction(title: "Test Action", desc: "Description", duration: 5, category: "test")]

        saveAndWait(sut, data: actions)

        let loadExpectation = expectation(description: "load completes")
        sut.load { result in
            switch result {
            case .success(let loaded):
                XCTAssertEqual(loaded.count, 1)
                XCTAssertEqual(loaded.first?.title, "Test Action")
                XCTAssertEqual(loaded.first?.duration, 5)
            case .failure:
                XCTFail("Should not fail loading saved data")
            }
            loadExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    // MARK: - Overwrite

    func testSaveOverwritesPreviousData() {
        let sut = PersistenceManager<[BreakAction]>(fileName: testFileName, defaultValue: [])
        let first = [BreakAction(title: "First", desc: "", duration: 1, category: "test")]
        let second = [BreakAction(title: "Second", desc: "", duration: 2, category: "test")]

        saveAndWait(sut, data: first)
        saveAndWait(sut, data: second)

        let loadExpectation = expectation(description: "load completes")
        sut.load { result in
            switch result {
            case .success(let loaded):
                XCTAssertEqual(loaded.count, 1)
                XCTAssertEqual(loaded.first?.title, "Second")
            case .failure:
                XCTFail("Should not fail")
            }
            loadExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    // MARK: - OptionSet Round Trip

    func testOptionSetSaveAndLoadRoundTrip() {
        let defaultOptions = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false)
        let sut = PersistenceManager<OptionSet>(fileName: testFileName, defaultValue: defaultOptions)
        let customOptions = OptionSet(breaktimeMin: 10, worktimeMin: 30, doesPlaySounds: true)

        saveAndWait(sut, data: customOptions)

        let loadExpectation = expectation(description: "load completes")
        sut.load { result in
            switch result {
            case .success(let loaded):
                XCTAssertEqual(loaded.breaktimeMin, 10)
                XCTAssertEqual(loaded.worktimeMin, 30)
                XCTAssertTrue(loaded.doesPlaySounds)
            case .failure(let error):
                XCTFail("Should not fail loading saved options: \(error)")
            }
            loadExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
