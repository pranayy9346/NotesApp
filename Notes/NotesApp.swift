//
//  NotesApp.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import SwiftUI

@main
struct NotesApp: App {
    @StateObject private var vm = NotesViewModel(store: UserDefaultsNoteStore())
    @StateObject private var lock = AppLockManager()

    var body: some Scene {
        WindowGroup {
          ContentView()
                .environmentObject(vm)
                .environmentObject(lock)  
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(NotesViewModel(store: PreviewNoteStore())) 
 // default init
        .environmentObject(AppLockManager())
}
