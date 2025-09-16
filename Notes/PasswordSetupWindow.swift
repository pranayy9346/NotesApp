//
//  PasswordSetupWindow.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import SwiftUI
import AppKit



struct PasswordSetupWindow: View {
    @ObservedObject var lock: AppLockManager
    @Environment(\.dismiss) private var dismiss
    @State private var newPassword = ""
    @State private var confirm = ""
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            SecureField("New Password", text: $newPassword)
            SecureField("Confirm Password", text: $confirm)
            HStack {
                Spacer()
                Button("Save") {
                    guard !newPassword.isEmpty, newPassword == confirm else {
                        message = "Passwords don't match."
                        return
                    }
                    do {
                        try lock.setPassword(newPassword)
                        message = "Password updated."
                        dismiss()
                    } catch {
                        message = "Failed: \(error.localizedDescription)"
                    }
                }
            }
            if let m = message { Text(m).foregroundStyle(.secondary) }
        }
        .padding(20)
        .frame(width: 340)
    }

    static func show(lock: AppLockManager) {
        let window = NSWindow()
        window.contentView = NSHostingView(rootView: PasswordSetupWindow(lock: lock))
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}


#Preview {
    PasswordSetupWindow(lock: .init())
}
