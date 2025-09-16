//
//  NoteStore.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import Foundation
import Combine

protocol NoteStore {
    func load() throws -> [Note]
    func save(_ notes: [Note]) throws
}

// MARK: - UserDefaults store (good for small data; simple demo)
final class UserDefaultsNoteStore: NoteStore {
    private let key = "SecureNotes.notes.v1"
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func load() throws -> [Note] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try decoder.decode([Note].self, from: data)
    }

    func save(_ notes: [Note]) throws {
        let data = try encoder.encode(notes)
        defaults.set(data, forKey: key)
    }
}
