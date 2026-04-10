
import Foundation

struct RecommendationDTO: Decodable, Identifiable, Hashable {
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

struct RecommendationsResponse: Decodable {
    let items: [RecommendationDTO]
}

struct OptimalSubscriptionResponse: Decodable {
    let subscription: SubscriptionDTO
    let explanation: String
}
