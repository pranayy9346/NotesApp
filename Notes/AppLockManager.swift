//
//  AppLockManager.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import Foundation
import LocalAuthentication
import CryptoKit
import Combine

final class AppLockManager: ObservableObject {
    @Published private(set) var isLocked: Bool = true
   
    func unlock() {
        isLocked = false
    }

    func requireLock() {
        isLocked = true
    }



    private let service = "com.example.SecureNotes.password"
    private let account = "app-lock"

    
    func setPassword(_ password: String) throws {
        let hash = Self.hash(password)
        do {
            try Keychain.savePasswordHash(hash, service: service, account: account)
        } catch KeychainError.duplicate {
            try Keychain.updatePasswordHash(hash, service: service, account: account)
        }
    }

    func clearPassword() {
        try? Keychain.delete(service: service, account: account)
    }

    func hasPassword() -> Bool {
        (try? Keychain.readPasswordHash(service: service, account: account)) != nil
    }

    func verifyPassword(_ password: String) -> Bool {
        guard let stored = try? Keychain.readPasswordHash(service: service, account: account) else { return false }
        return stored == Self.hash(password)
    }

    // Try biometrics first, then fall back to password UI you provide.
    func unlockWithBiometrics(reason: String = "Unlock your notes", completion: @escaping (Bool, Error?) -> Void) {
        let ctx = LAContext()
        var error: NSError?

        // Prefer full device authentication to allow system password fallback on macOS.
        let policy: LAPolicy = .deviceOwnerAuthentication

        if ctx.canEvaluatePolicy(policy, error: &error) {
            ctx.evaluatePolicy(policy, localizedReason: reason) { success, evalError in
                DispatchQueue.main.async {
                    if success {
                        self.isLocked = false
                        completion(true, nil)
                    } else {
                        completion(false, evalError)
                    }
                }
            }
        } else {
            // Biometrics unavailable; caller should present password UI
            completion(false, error)
        }
    }

    private static func hash(_ password: String) -> Data {
        Data(SHA256.hash(data: Data(password.utf8)))
    }
}

