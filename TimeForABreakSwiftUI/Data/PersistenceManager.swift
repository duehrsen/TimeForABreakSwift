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

    func save(data: T, completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let encoded = try JSONEncoder().encode(data)
                let outfile = try self.fileURL()
                try encoded.write(to: outfile)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func load(completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileUrl = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
                    DispatchQueue.main.async {
                        completion(.success(self.defaultValue))
                    }
                    return
                }
                let decoded = try JSONDecoder().decode(T.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func saveToDisk(data: T) {
        save(data: data) { result in
            if case .failure(let error) = result {
                print("[PersistenceManager] Failed to save \(self.fileName): \(error.localizedDescription)")
            }
        }
    }
}
