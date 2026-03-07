//
//  DataMigration.swift
//  TimeForABreakSwiftUI
//

import Foundation

enum DataMigration {

    /// Maps old category strings to new category IDs.
    private static let categoryMapping: [String: String] = [
        "regular": "chores",
        "relax": "mental",
        "clean": "chores",
        "exercise": "exercise",
        "external": "mental"
    ]

    /// Migrates an array of BreakActions, updating any old category IDs to new ones.
    /// Actions already using new category IDs are left unchanged.
    static func migrateCategories(in actions: [BreakAction]) -> [BreakAction] {
        actions.map { action in
            guard let newCategoryId = categoryMapping[action.categoryId] else {
                return action
            }
            var migrated = action
            migrated.categoryId = newCategoryId
            return migrated
        }
    }
}
