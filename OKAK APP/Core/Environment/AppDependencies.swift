
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
    let chatService: ChatServiceType
    let catalogService: CatalogServiceType
    let ordersService: OrdersServiceType
    let subscriptionsService: SubscriptionsServiceType
    let recommendationsService: RecommendationsServiceType

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
        let sse = SSEClient(api: api)
        self.sse = sse
        self.authService = AuthService(api: api, session: session)
        self.chatService = ChatService(api: api, sse: sse)
        self.catalogService = CatalogService(api: api)
        self.ordersService = OrdersService(api: api)
        self.subscriptionsService = SubscriptionsService(api: api)
        self.recommendationsService = RecommendationsService(api: api)
    }
}
