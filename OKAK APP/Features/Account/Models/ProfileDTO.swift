
import Foundation

struct ProfileDTO: Decodable, Hashable, Sendable {
    let id: String
    let userId: String
    let displayName: String?
    let language: String
    let theme: String
    let communicationStyle: String?
    let interests: [String]
    let aiPersonalizationEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case displayName = "display_name"
        case language
        case theme
        case communicationStyle = "communication_style"
        case interests
        case aiPersonalizationEnabled = "ai_personalization_enabled"
    }
}

struct UpdateProfileRequest: Encodable {
    let displayName: String?
    let language: String?
    let theme: String?
    let communicationStyle: String?
    let interests: [String]?
    let aiPersonalizationEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case language
        case theme
        case communicationStyle = "communication_style"
        case interests
        case aiPersonalizationEnabled = "ai_personalization_enabled"
    }
}
