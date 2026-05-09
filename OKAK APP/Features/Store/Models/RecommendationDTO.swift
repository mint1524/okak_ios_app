
import Foundation

struct RecommendationDTO: Decodable, Identifiable, Hashable, Sendable {
    let id: String
    let subscriptionId: String
    let title: String
    let reason: String
    let confidence: Double

    enum CodingKeys: String, CodingKey {
        case id
        case subscriptionId = "subscription_id"
        case title
        case reason
        case confidence
    }
}

struct RecommendationsResponse: Decodable, Sendable {
    let items: [RecommendationDTO]
}

struct OptimalSubscriptionResponse: Decodable, Sendable {
    let subscription: SubscriptionDTO
    let explanation: String
}
