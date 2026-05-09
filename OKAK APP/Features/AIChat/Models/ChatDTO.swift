
import Foundation

struct ChatDTO: Identifiable, Decodable, Hashable, Sendable {
    let id: String
    let title: String
    let model: String
    let reasoningLevel: String
    let searchEnabled: Bool
    let streamingEnabled: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case model
        case reasoningLevel = "reasoning_level"
        case searchEnabled = "search_enabled"
        case streamingEnabled = "streaming_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ChatListResponse: Decodable, Sendable {
    let items: [ChatDTO]
}

enum MessageRole: String, Decodable, Encodable, Sendable {
    case user
    case assistant
    case system
}

enum MessageStatus: String, Decodable, Sendable {
    case pending
    case streaming
    case completed
    case failed
}

struct MessageAttachment: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let name: String
    let mimeType: String
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case mimeType = "mime_type"
        case url
    }
}

struct MessageDTO: Identifiable, Decodable, Hashable, Sendable {
    let id: String
    let chatId: String
    let role: MessageRole
    var content: String
    var status: MessageStatus
    let tokenCount: Int?
    let attachments: [MessageAttachment]
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case role
        case content
        case status
        case tokenCount = "token_count"
        case attachments
        case createdAt = "created_at"
    }
}

struct MessageListResponse: Decodable, Sendable {
    let items: [MessageDTO]
}

struct CreateChatRequest: Encodable {
    let title: String?
    let model: String?
    let reasoningLevel: String?
    let searchEnabled: Bool?
    let streamingEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case title
        case model
        case reasoningLevel = "reasoning_level"
        case searchEnabled = "search_enabled"
        case streamingEnabled = "streaming_enabled"
    }
}

struct UpdateChatRequest: Encodable {
    let title: String?

    enum CodingKeys: String, CodingKey { case title }
}

struct UpdateChatParametersRequest: Encodable {
    let model: String?
    let reasoningLevel: String?
    let searchEnabled: Bool?
    let streamingEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case model
        case reasoningLevel = "reasoning_level"
        case searchEnabled = "search_enabled"
        case streamingEnabled = "streaming_enabled"
    }
}

struct SendMessageRequest: Encodable {
    let content: String
    let attachments: [String]?
}

struct SendMessageResponse: Decodable, Sendable {
    let userMessage: MessageDTO
    let assistantMessage: MessageDTO

    enum CodingKeys: String, CodingKey {
        case userMessage = "user_message"
        case assistantMessage = "assistant_message"
    }
}

struct QuotaDTO: Decodable, Equatable, Sendable {
    let planName: String
    let limit: Int
    let used: Int
    let resetAt: Date?

    var remaining: Int { max(0, limit - used) }

    enum CodingKeys: String, CodingKey {
        case planName = "plan_name"
        case limit
        case used
        case resetAt = "reset_at"
    }
}

enum ChatStreamEvent: Decodable, Sendable {
    case start(messageId: String)
    case delta(String)
    case toolUse(String)
    case done(MessageDTO)
    case quota(QuotaDTO)
    case error(String)

    private enum Kind: String, Decodable { case start, delta, tool_use, done, quota, error }
    private enum CodingKeys: String, CodingKey { case type, content, message, message_id, quota }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .type)
        switch kind {
        case .start:
            let id = try c.decode(String.self, forKey: .message_id)
            self = .start(messageId: id)
        case .delta:
            self = .delta(try c.decode(String.self, forKey: .content))
        case .tool_use:
            self = .toolUse(try c.decode(String.self, forKey: .content))
        case .done:
            self = .done(try c.decode(MessageDTO.self, forKey: .message))
        case .quota:
            self = .quota(try c.decode(QuotaDTO.self, forKey: .quota))
        case .error:
            self = .error(try c.decode(String.self, forKey: .message))
        }
    }
}
