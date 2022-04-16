//
//  OptionsModel.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-15.
//

import SwiftUI

struct OptionSet : Codable {
    var breaktimeMin : Int
    var worktimeMin : Int
    var doesPlaySounds : Bool
}

class OptionsModel : ObservableObject {
        
    private var fileBase : String = "options"
    
    static let defaultOptions : OptionSet = OptionSet(breaktimeMin: 5, worktimeMin: 20, doesPlaySounds: false)
    
    @Published var options : OptionSet = defaultOptions
    
    private func fileURL() throws -> URL {
        
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("\(fileBase).data")
        
    }
    
    func setDefault() {
        options = OptionsModel.defaultOptions
        saveToDisk()
    }
    
    func updateOptionsModel(breakMin: Int, workMin: Int, doesPlaySounds: Bool) {
        options.breaktimeMin = breakMin
        options.worktimeMin = workMin
        options.doesPlaySounds = doesPlaySounds
        print("Updated Options")
    }
    
    func save(options: OptionSet, completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(options)
                let outfile = try self.fileURL()
                try data.write(to: outfile)
                print ("Saved to \(outfile)")
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func load(completion: @escaping (Result<OptionSet, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileUrl = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
                    DispatchQueue.main.async {
                        completion(.success(OptionsModel.defaultOptions))
                    }
                    return
                }
                let optionSet = try JSONDecoder().decode(OptionSet.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(optionSet))
                    print("Loaded successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }
        
    }
    
    func saveToDisk() {
        self.save(options: options) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
}
