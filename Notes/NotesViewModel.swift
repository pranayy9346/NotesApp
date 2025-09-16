//
//  NotesViewModel.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import Foundation
import Combine
import SwiftUI   // ✅ correct

final class NotesViewModel: ObservableObject {
    // Published state for views to observe
    @Published var searchText: String = ""
    @Published var notes: [Note] = []
    @Published private(set) var isLocked: Bool = true



    // UI routing state
    @Published var editorPresented: Bool = false
    @Published var editorNote: Note = Note(title: "", body: "")

    private let store: NoteStore
    private var cancellables: Set<AnyCancellable> = []

    init(store: NoteStore) {
        self.store = store
        // Load at startup
        do { notes = try store.load() } catch { print("Load error: \(error)") }
        // Optional: simple debounce for search heavy lists
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(120), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // Filtered view of notes
    var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notes.sorted { $0.updatedAt > $1.updatedAt } }
        let q = searchText.lowercased()
        return notes.filter { $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q) }
                    .sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - CRUD
    func startAdding() {
        editorNote = Note(title: "", body: "")
        editorPresented = true
    }

    func startEditing(_ note: Note) {
        editorNote = note
        editorPresented = true
    }

    func saveEditorNote() {
        var draft = editorNote
        draft.updatedAt = Date()

        if let idx = notes.firstIndex(where: { $0.id == draft.id }) {
            notes[idx] = draft
        } else {
            notes.insert(draft, at: 0)
        }
        persist()
        editorPresented = false
    }

    func delete(at offsets: IndexSet) {
        let ids = offsets.map { filteredNotes[$0].id }
        notes.removeAll { ids.contains($0.id) }
        persist()
    }

    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        persist()
    }

    private func persist() {
        do { try store.save(notes) } catch { print("Save error: \(error)") }
    }
}

// MARK: - Convenience CRUD for UI
extension NotesViewModel {
    func addNote() {
        let newNote = Note(title: "New Note", body: "")
        notes.insert(newNote, at: 0)
        saveNotes()
    }

    func saveNotes() {
        do {
            try store.save(notes)
        } catch {
            print("Save error: \(error)")
        }
    }

    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
}
