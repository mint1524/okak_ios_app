
import Foundation
import SwiftUI

@MainActor
final class AppDependencies: ObservableObject {
    let configuration: AppConfiguration
    let keychain: KeychainStoreType
    let session: SessionStore
    let api: APIClientType
    let sse: SSEClientType
    let authService: AuthServiceType

    init(configuration: AppConfiguration = .default) {
        self.configuration = configuration
        let keychain = KeychainStore()
        self.keychain = keychain
        let session = SessionStore(keychain: keychain)
        self.session = session

        weak var weakSession: SessionStore? = session
        let api = APIClient(
            baseURL: configuration.apiBaseURL,
            tokenProvider: {
                await MainActor.run { weakSession?.accessToken() }
            },
            onUnauthorized: {
                await MainActor.run { weakSession?.signOut() }
            }
        )
        self.api = api
        self.sse = SSEClient(api: api)
        self.authService = AuthService(api: api, session: session)
    }
}
