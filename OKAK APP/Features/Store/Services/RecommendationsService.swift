
import Foundation

protocol RecommendationsServiceType: AnyObject, Sendable {
    func list() async throws -> [RecommendationDTO]
    func optimal() async throws -> OptimalSubscriptionResponse
}

final class RecommendationsService: RecommendationsServiceType, @unchecked Sendable {
    private let api: APIClientType
    init(api: APIClientType) { self.api = api }

    func list() async throws -> [RecommendationDTO] {
        let endpoint = APIEndpoint(method: .get, path: "recommendations")
        return try await api.send(endpoint, as: RecommendationsResponse.self).items
    }

    func optimal() async throws -> OptimalSubscriptionResponse {
        let endpoint = APIEndpoint(method: .post, path: "recommendations/optimal-subscription")
        return try await api.send(endpoint, as: OptimalSubscriptionResponse.self)
    }
}
