//
//  NoteEditorView.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import SwiftUI

struct NoteEditorView: View {
    @Binding var note: Note
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: $note.title)
                .font(.title2)
            Divider()
            TextEditor(text: $note.body)
                .font(.body)
                .overlay(alignment: .topLeading) {
                    if note.body.isEmpty {
                        Text("Start typing…")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                }

            HStack {
                Spacer()
                Button("Save") { onSave() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
}
#Preview {
    NoteEditorView(
        note: .constant(Note(id: UUID(), title: "Sample Title", body: "Sample body text")),
        onSave: {}
    )
}

