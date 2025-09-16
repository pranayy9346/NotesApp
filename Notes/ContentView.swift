import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: NotesViewModel
    @EnvironmentObject private var lock: AppLockManager

    var body: some View {
        ZStack {
            MainSplitView()
            if lock.isLocked {
                LockOverlay()
            }
        }
    }
}

private struct MainSplitView: View {
    @EnvironmentObject private var vm: NotesViewModel
    @EnvironmentObject private var lock: AppLockManager

    var body: some View {
        NavigationSplitView {
            SidebarList()
        } detail: {
            EditorArea()
        }
    }
}

// MARK: - Sidebar
private struct SidebarList: View {
    @EnvironmentObject private var vm: NotesViewModel
    @EnvironmentObject private var lock: AppLockManager

    var body: some View {
        List {
            if vm.filteredNotes.isEmpty {
                ContentEmptyState()
            } else {
                Section("All Notes") {
                    ForEach(vm.filteredNotes) { note in
                        NoteRowButton(note: note)
                    }
                    .onDelete(perform: vm.delete)
                }
            }
        }
        .navigationTitle("📝 My Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { vm.startAdding() } label: {
                    Label("New Note", systemImage: "plus.circle.fill")
                }
            }
            ToolbarItem {
                Button { lock.requireLock() } label: {
                    Label("Lock", systemImage: "lock.fill")
                }
            }
        }
        .searchable(text: $vm.searchText, placement: .sidebar, prompt: "Search notes")
    }
}

private struct NoteRowButton: View {
    @EnvironmentObject private var vm: NotesViewModel
    let note: Note

    var body: some View {
        Button { vm.startEditing(note) } label: {
            NoteRow(note: note)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Edit") { vm.startEditing(note) }
            Button(role: .destructive) { vm.delete(note) } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// ✅ NoteRow implementation
private struct NoteRow: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(note.body.isEmpty ? "No content" : note.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(note.updatedAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Editor Area
private struct EditorArea: View {
    @EnvironmentObject private var vm: NotesViewModel

    var body: some View {
        if vm.editorPresented {
            NoteEditorView(note: $vm.editorNote, onSave: vm.saveEditorNote)
                .padding()
                .frame(minWidth: 480, minHeight: 320)
        } else {
            EmptyDetailPlaceholder()
        }
    }
}

// MARK: - Empty States
private struct EmptyDetailPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Select a note to view or edit")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ContentEmptyState: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No Notes Yet")
                .font(.headline)
            Text("Tap + to create your first note.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// ✅ LockOverlay implementation
private struct LockOverlay: View {
    @EnvironmentObject private var lock: AppLockManager
    @State private var password: String = ""
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
            Text("Locked").font(.title2)

            if lock.hasPassword() {
                SecureField("Password", text: $password)
                    .frame(width: 260)
                Button("Unlock with Password") {
                    if lock.verifyPassword(password) {
                        lock.unlock()   // ✅ use helper
                    } else {
                        errorText = "Incorrect password."
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Unlock with Touch ID") {
                lock.unlockWithBiometrics { success, err in
                    if !success {
                        errorText = err?.localizedDescription ?? "Authentication failed."
                    }
                }
            }

            if let err = errorText {
                Text(err).foregroundStyle(.red)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
