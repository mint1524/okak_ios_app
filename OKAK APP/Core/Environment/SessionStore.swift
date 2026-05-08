
import Foundation
import Combine
import os

@MainActor
final class SessionStore: ObservableObject {
    enum State: Equatable {
        case unknown
        case unauthenticated
        case pendingEmailVerification(email: String)
        case authenticated(userID: String)
    }

    @Published private(set) var state: State = .unknown
    @Published var lastError: String?

    private let keychain: KeychainStoreType

    init(keychain: KeychainStoreType) {
        self.keychain = keychain
    }

    func restore() async {
        do {
            if let pending = try keychain.get(KeychainKey.pendingEmail), !pending.isEmpty {
                state = .pendingEmailVerification(email: pending)
                return
            }
            if let userID = try keychain.get(KeychainKey.userID),
               (try keychain.get(KeychainKey.accessToken)) != nil {
                state = .authenticated(userID: userID)
                return
            }
            state = .unauthenticated
        } catch {
            OKLog.auth.error("session restore failed: \(error.localizedDescription, privacy: .public)")
            state = .unauthenticated
        }
    }

    func accessToken() -> String? {
        (try? keychain.get(KeychainKey.accessToken))
    }

    func refreshToken() -> String? {
        (try? keychain.get(KeychainKey.refreshToken))
    }

    func setTokens(access: String, refresh: String, userID: String) throws {
        try keychain.set(access, for: KeychainKey.accessToken)
        try keychain.set(refresh, for: KeychainKey.refreshToken)
        try keychain.set(userID, for: KeychainKey.userID)
        try? keychain.remove(KeychainKey.pendingEmail)
        state = .authenticated(userID: userID)
    }

    func markPendingVerification(email: String) throws {
        try keychain.set(email, for: KeychainKey.pendingEmail)
        state = .pendingEmailVerification(email: email)
    }

    func signOut() {
        try? keychain.remove(KeychainKey.accessToken)
        try? keychain.remove(KeychainKey.refreshToken)
        try? keychain.remove(KeychainKey.userID)
        try? keychain.remove(KeychainKey.pendingEmail)
        state = .unauthenticated
    }
}
