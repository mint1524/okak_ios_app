
import Foundation

protocol CatalogServiceType: AnyObject, Sendable {
    func list(type: String?) async throws -> [SubscriptionDTO]
    func get(id: String) async throws -> SubscriptionDTO
}

final class CatalogService: CatalogServiceType, @unchecked Sendable {
    private let api: APIClientType
    init(api: APIClientType) { self.api = api }

    func list(type: String?) async throws -> [SubscriptionDTO] {
        var endpoint = APIEndpoint(method: .get, path: "catalog/subscriptions")
        if let type, !type.isEmpty {
            endpoint.query = [URLQueryItem(name: "type", value: type)]
        }
        return try await api.send(endpoint, as: SubscriptionsListResponse.self).items
    }

    func get(id: String) async throws -> SubscriptionDTO {
        let endpoint = APIEndpoint(method: .get, path: "catalog/subscriptions/\(id)")
        return try await api.send(endpoint, as: SubscriptionDTO.self)
    }
}
