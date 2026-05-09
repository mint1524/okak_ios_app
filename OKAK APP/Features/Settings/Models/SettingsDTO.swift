
import Foundation

struct AppSettingsDTO: Decodable, Hashable, Sendable {
    let language: String
    let theme: String
    let notificationsEnabled: Bool
    let analyticsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case language
        case theme
        case notificationsEnabled = "notifications_enabled"
        case analyticsEnabled = "analytics_enabled"
    }
}

struct UpdateSettingsRequest: Encodable {
    let language: String?
    let theme: String?
    let notificationsEnabled: Bool?
    let analyticsEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case language
        case theme
        case notificationsEnabled = "notifications_enabled"
        case analyticsEnabled = "analytics_enabled"
    }
}
