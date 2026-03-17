//
//  SelectedActionsViewModelTests.swift
//  TimeForABreakSwiftUITests
//

import XCTest
@testable import Time_For_A_Break

@MainActor
final class SelectedActionsViewModelTests: XCTestCase {

    private var sut: SelectedActionsViewModel!

    override func setUp() {
        super.setUp()
        sut = SelectedActionsViewModel()
        sut.emptyData()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSetTodaysActionsReplacesTodaysNonPinned() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        // Existing today, non-pinned
        let existingToday = BreakAction(
            title: "Old today",
            description: "",
            categoryId: "mental",
            duration: 5,
            pinned: false,
            completed: false,
            date: today
        )

        // Existing pinned
        let pinned = BreakAction(
            title: "Pinned",
            description: "",
            categoryId: "mental",
            duration: 5,
            pinned: true,
            completed: false,
            date: today
        )

        // Existing yesterday
        let existingYesterday = BreakAction(
            title: "Yesterday",
            description: "",
            categoryId: "mental",
            duration: 5,
            pinned: false,
            completed: false,
            date: yesterday
        )

        sut.actions = [existingToday, pinned, existingYesterday]

        // New templates for today
        let templates = [
            BreakAction(title: "Walk", description: "", categoryId: "mental", duration: 5),
            BreakAction(title: "Stretch", description: "", categoryId: "mental", duration: 3)
        ]

        sut.setTodaysActions(from: templates)

        let todayActions = sut.actions.filter { Calendar.current.isDateInToday($0.date ?? .distantPast) }
        let titles = todayActions.map { $0.title }

        // Old today action replaced
        XCTAssertFalse(titles.contains("Old today"))
        // Pinned preserved
        XCTAssertTrue(titles.contains("Pinned"))
        // New actions present
        XCTAssertTrue(titles.contains("Walk"))
        XCTAssertTrue(titles.contains("Stretch"))

        // Yesterday action untouched
        XCTAssertTrue(sut.actions.contains(where: { $0.title == "Yesterday" }))
    }

    func testCountedHistoryActionsAggregatesFrequenciesByTitle() {
        let today = Date()
        let a1 = BreakAction(title: "Walk", description: "", categoryId: "mental", duration: 5, completed: true, date: today)
        let a2 = BreakAction(title: "Walk", description: "", categoryId: "mental", duration: 5, completed: true, date: today)
        let a3 = BreakAction(title: "Stretch", description: "", categoryId: "mental", duration: 3, completed: true, date: today)

        let result = sut.countedHistoryActions(actions: [a1, a2, a3])
        XCTAssertEqual(result.count, 2)

        let walk = result.first { $0.title == "Walk" }
        XCTAssertEqual(walk?.frequency, 2)

        let stretch = result.first { $0.title == "Stretch" }
        XCTAssertEqual(stretch?.frequency, 1)
    }
}

