//
//  SecureNotesApp.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import Foundation
import SwiftUI

struct SecureNotesApp: App {
    // Single source of truth for view model and lock manager
    @StateObject private var notesVM = NotesViewModel(store: UserDefaultsNoteStore())
    @StateObject private var lock = AppLockManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notesVM)
                .environmentObject(lock)
                // Require auth when app becomes active again
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)) { _ in
                    lock.requireLock()
                }
        }
        .commands {
            // Optional: quick new note shortcut
            CommandGroup(after: .newItem) {
                Button("New Note") { notesVM.startAdding() }
                    .keyboardShortcut("n", modifiers: [.command])
            }
        }
    }
}
