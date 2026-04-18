
import Foundation

struct SessionDTO: Identifiable, Decodable, Hashable {
    let id: String
    let deviceName: String
    let deviceType: String
    let ipAddress: String
    let userAgent: String?
    let isCurrent: Bool
    let createdAt: Date
    let lastActiveAt: Date
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case deviceName = "device_name"
        case deviceType = "device_type"
        case ipAddress = "ip_address"
        case userAgent = "user_agent"
        case isCurrent = "is_current"
        case createdAt = "created_at"
        case lastActiveAt = "last_active_at"
        case expiresAt = "expires_at"
    }
}

struct SessionsListResponse: Decodable {
    let items: [SessionDTO]
}
