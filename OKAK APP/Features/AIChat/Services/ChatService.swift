
import Foundation

protocol ChatServiceType: AnyObject, Sendable {
    func listChats() async throws -> [ChatDTO]
    func createChat(title: String?) async throws -> ChatDTO
    func getChat(id: String) async throws -> ChatDTO
    func renameChat(id: String, title: String) async throws -> ChatDTO
    func deleteChat(id: String) async throws
    func updateParameters(id: String, params: UpdateChatParametersRequest) async throws -> ChatDTO

    func listMessages(chatId: String) async throws -> [MessageDTO]
    func sendMessage(chatId: String, content: String, attachments: [String]) async throws -> SendMessageResponse
    func streamMessage(chatId: String, content: String, attachments: [String]) -> AsyncThrowingStream<ChatStreamEvent, Error>

    func currentQuota() async throws -> QuotaDTO
}

final class ChatService: ChatServiceType, @unchecked Sendable {
    private let api: APIClientType
    private let sse: SSEClientType
    private let decoder: JSONDecoder

    init(api: APIClientType, sse: SSEClientType) {
        self.api = api
        self.sse = sse
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func listChats() async throws -> [ChatDTO] {
        let endpoint = APIEndpoint(method: .get, path: "chats")
        return try await api.send(endpoint, as: ChatListResponse.self).items
    }

    func createChat(title: String?) async throws -> ChatDTO {
        var endpoint = APIEndpoint(method: .post, path: "chats")
        endpoint.body = try APIEndpoint.jsonBody(CreateChatRequest(
            title: title,
            model: nil,
            reasoningLevel: nil,
            searchEnabled: nil,
            streamingEnabled: nil
        ))
        return try await api.send(endpoint, as: ChatDTO.self)
    }

    func getChat(id: String) async throws -> ChatDTO {
        let endpoint = APIEndpoint(method: .get, path: "chats/\(id)")
        return try await api.send(endpoint, as: ChatDTO.self)
    }

    func renameChat(id: String, title: String) async throws -> ChatDTO {
        var endpoint = APIEndpoint(method: .patch, path: "chats/\(id)")
        endpoint.body = try APIEndpoint.jsonBody(UpdateChatRequest(title: title))
        return try await api.send(endpoint, as: ChatDTO.self)
    }

    func deleteChat(id: String) async throws {
        let endpoint = APIEndpoint(method: .delete, path: "chats/\(id)")
        try await api.sendVoid(endpoint)
    }

    func updateParameters(id: String, params: UpdateChatParametersRequest) async throws -> ChatDTO {
        var endpoint = APIEndpoint(method: .patch, path: "chats/\(id)/parameters")
        endpoint.body = try APIEndpoint.jsonBody(params)
        return try await api.send(endpoint, as: ChatDTO.self)
    }

    func listMessages(chatId: String) async throws -> [MessageDTO] {
        let endpoint = APIEndpoint(method: .get, path: "chats/\(chatId)/messages")
        return try await api.send(endpoint, as: MessageListResponse.self).items
    }

    func sendMessage(chatId: String, content: String, attachments: [String]) async throws -> SendMessageResponse {
        var endpoint = APIEndpoint(method: .post, path: "chats/\(chatId)/messages")
        endpoint.body = try APIEndpoint.jsonBody(SendMessageRequest(content: content, attachments: attachments.isEmpty ? nil : attachments))
        return try await api.send(endpoint, as: SendMessageResponse.self)
    }

    func streamMessage(chatId: String, content: String, attachments: [String]) -> AsyncThrowingStream<ChatStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var endpoint = APIEndpoint(method: .post, path: "chats/\(chatId)/messages/stream")
                    endpoint.body = try APIEndpoint.jsonBody(SendMessageRequest(
                        content: content,
                        attachments: attachments.isEmpty ? nil : attachments
                    ))
                    let stream = self.sse.events(for: endpoint)
                    for try await event in stream {
                        guard let data = event.data.data(using: .utf8) else { continue }
                        do {
                            let parsed = try self.decoder.decode(ChatStreamEvent.self, from: data)
                            continuation.yield(parsed)
                        } catch {
                            OKLog.chat.error("stream decode failed: \(error.localizedDescription, privacy: .public)")
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func currentQuota() async throws -> QuotaDTO {
        let endpoint = APIEndpoint(method: .get, path: "quota")
        return try await api.send(endpoint, as: QuotaDTO.self)
    }
}
