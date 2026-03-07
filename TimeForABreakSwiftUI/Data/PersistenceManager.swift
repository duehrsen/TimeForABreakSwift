//
//  PersistenceManager.swift
//  TimeForABreakSwiftUI
//
//  Created on 2026-03-03.
//

import Foundation

class PersistenceManager<T: Codable> {

    private let fileName: String
    private let defaultValue: T

    init(fileName: String, defaultValue: T) {
        self.fileName = fileName
        self.defaultValue = defaultValue
    }

    private func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("\(fileName).data")
    }

    func save(data: T) async throws {
        let encoded = try JSONEncoder().encode(data)
        let outfile = try fileURL()
        try encoded.write(to: outfile)
    }

    func load() async throws -> T {
        let fileUrl = try fileURL()
        guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
            return defaultValue
        }
        return try JSONDecoder().decode(T.self, from: file.availableData)
    }

    func saveToDisk(data: T) {
        Task {
            do {
                try await save(data: data)
            } catch {
                print("[PersistenceManager] Failed to save \(self.fileName): \(error.localizedDescription)")
            }
        }
    }
}
