
import Foundation

protocol SubscriptionsServiceType: AnyObject, Sendable {
    func active() async throws -> [UserSubscriptionDTO]
    func cancel(id: String) async throws -> UserSubscriptionDTO
    func renew(id: String) async throws -> UserSubscriptionDTO
}

final class SubscriptionsService: SubscriptionsServiceType, @unchecked Sendable {
    private let api: APIClientType
    init(api: APIClientType) { self.api = api }

    func active() async throws -> [UserSubscriptionDTO] {
        let endpoint = APIEndpoint(method: .get, path: "subscriptions/active")
        return try await api.send(endpoint, as: UserSubscriptionsResponse.self).items
    }

    func cancel(id: String) async throws -> UserSubscriptionDTO {
        let endpoint = APIEndpoint(method: .post, path: "subscriptions/\(id)/cancel")
        return try await api.send(endpoint, as: UserSubscriptionDTO.self)
    }

    func renew(id: String) async throws -> UserSubscriptionDTO {
        let endpoint = APIEndpoint(method: .post, path: "subscriptions/\(id)/renew")
        return try await api.send(endpoint, as: UserSubscriptionDTO.self)
    }
}
