//
//  PreviewNoteStore.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

//
//  PreviewNoteStore.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import Foundation
import SwiftUI

// MARK: - Preview Note Store (Fake data for SwiftUI Previews)
final class PreviewNoteStore: NoteStore {
    private var sampleNotes: [Note] = [
        Note(id: UUID(), title: "Sample Note 1", body: "Body of note 1"),
        Note(id: UUID(), title: "Sample Note 2", body: "Body of note 2")
    ]

    func load() throws -> [Note] {
        return sampleNotes
    }

    func save(_ notes: [Note]) throws {
        // No-op in preview (we don’t persist anything)
    }
}

// MARK: - SwiftUI Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NotesViewModel(store: PreviewNoteStore())) // ✅ fake store for preview
            .environmentObject(AppLockManager())
    }
}
