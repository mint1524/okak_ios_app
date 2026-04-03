
import Foundation

struct SubscriptionDTO: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let currency: String
    let durationDays: Int
    let type: String
    let status: String
    let quotaLimit: Int
    let features: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case currency
        case durationDays = "duration_days"
        case type
        case status
        case quotaLimit = "quota_limit"
        case features
    }
}

struct SubscriptionsListResponse: Decodable {
    let items: [SubscriptionDTO]
}

struct UserSubscriptionDTO: Identifiable, Decodable, Hashable {
    let id: String
    let subscriptionId: String
    let name: String
    let status: String
    let startDate: Date
    let endDate: Date
    let autoRenew: Bool
    let quotaLimit: Int

    enum CodingKeys: String, CodingKey {
        case id
        case subscriptionId = "subscription_id"
        case name
        case status
        case startDate = "start_date"
        case endDate = "end_date"
        case autoRenew = "auto_renew"
        case quotaLimit = "quota_limit"
    }
}

struct UserSubscriptionsResponse: Decodable {
    let items: [UserSubscriptionDTO]
}
