
import Testing
import Foundation
@testable import OKAK_APP

@MainActor
struct ChatDetailViewModelTests {
    @Test func cannotSendWhenQuotaExhausted() async {
        let mock = MockChatService()
        mock.quota = QuotaDTO(planName: "free", limit: 5, used: 5, resetAt: nil)
        let chat = ChatDTO(
            id: "c1", title: "Test", model: "okak-mini",
            reasoningLevel: "medium", searchEnabled: false, streamingEnabled: false,
            createdAt: Date(), updatedAt: Date()
        )
        let vm = ChatDetailViewModel(chat: chat, service: mock)
        await vm.load()
        vm.draft = "Hello"
        await vm.send()
        #expect(vm.errorMessage == APIError.quotaExceeded.errorDescription)
        #expect(vm.messages.isEmpty)
    }

    @Test func nonStreamingAppendsBothMessages() async {
        let mock = MockChatService()
        let chat = ChatDTO(
            id: "c1", title: "Test", model: "okak-mini",
            reasoningLevel: "medium", searchEnabled: false, streamingEnabled: false,
            createdAt: Date(), updatedAt: Date()
        )
        let vm = ChatDetailViewModel(chat: chat, service: mock)
        vm.draft = "Hi"
        await vm.send()
        #expect(vm.messages.count == 2)
        #expect(vm.messages.first?.role == .user)
        #expect(vm.messages.last?.role == .assistant)
    }
}

final class MockChatService: ChatServiceType, @unchecked Sendable {
    var quota: QuotaDTO = QuotaDTO(planName: "free", limit: 50, used: 0, resetAt: nil)

    func listChats() async throws -> [ChatDTO] { [] }
    func createChat(title: String?) async throws -> ChatDTO {
        ChatDTO(id: "c1", title: title ?? "Новый чат", model: "okak-mini",
                reasoningLevel: "medium", searchEnabled: false, streamingEnabled: false,
                createdAt: Date(), updatedAt: Date())
    }
    func getChat(id: String) async throws -> ChatDTO {
        try await createChat(title: nil)
    }
    func renameChat(id: String, title: String) async throws -> ChatDTO {
        try await createChat(title: title)
    }
    func deleteChat(id: String) async throws {}
    func updateParameters(id: String, params: UpdateChatParametersRequest) async throws -> ChatDTO {
        try await createChat(title: nil)
    }
    func listMessages(chatId: String) async throws -> [MessageDTO] { [] }
    func sendMessage(chatId: String, content: String, attachments: [String]) async throws -> SendMessageResponse {
        let now = Date()
        return SendMessageResponse(
            userMessage: MessageDTO(id: "m1", chatId: chatId, role: .user, content: content,
                                    status: .completed, tokenCount: nil, attachments: [], createdAt: now),
            assistantMessage: MessageDTO(id: "m2", chatId: chatId, role: .assistant, content: "Hi back",
                                         status: .completed, tokenCount: 2, attachments: [], createdAt: now)
        )
    }
    func streamMessage(chatId: String, content: String, attachments: [String]) -> AsyncThrowingStream<ChatStreamEvent, Error> {
        AsyncThrowingStream { continuation in continuation.finish() }
    }
    func currentQuota() async throws -> QuotaDTO { quota }
}
