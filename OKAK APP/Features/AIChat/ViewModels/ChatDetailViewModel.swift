
import Foundation
import Combine

@MainActor
final class ChatDetailViewModel: ObservableObject {
    @Published private(set) var chat: ChatDTO
    @Published private(set) var messages: [MessageDTO] = []
    @Published var draft: String = ""
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String?
    @Published var quota: QuotaDTO?
    @Published var pendingAttachments: [String] = []

    let service: ChatServiceType
    private var streamingTask: Task<Void, Never>?

    init(chat: ChatDTO, service: ChatServiceType) {
        self.chat = chat
        self.service = service
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        async let msgsAsync = try? service.listMessages(chatId: chat.id)
        async let quotaAsync = try? service.currentQuota()
        let (loaded, q) = await (msgsAsync, quotaAsync)
        if let loaded { messages = loaded }
        if let q { quota = q }
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        if let quota, quota.remaining <= 0 {
            errorMessage = APIError.quotaExceeded.errorDescription
            return
        }
        draft = ""
        errorMessage = nil
        isSending = true
        if chat.streamingEnabled {
            await streamReply(content: text)
        } else {
            await sendNonStreaming(content: text)
        }
        isSending = false
    }

    private func sendNonStreaming(content: String) async {
        do {
            let response = try await service.sendMessage(chatId: chat.id, content: content, attachments: pendingAttachments)
            messages.append(response.userMessage)
            messages.append(response.assistantMessage)
            pendingAttachments.removeAll()
            if let q = try? await service.currentQuota() { quota = q }
        } catch let api as APIError {
            handleStreamError(api)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func streamReply(content: String) async {
        let placeholderUserId = "tmp-\(UUID().uuidString)"
        let placeholderAssistantId = "tmp-asst-\(UUID().uuidString)"
        let userMessage = MessageDTO(
            id: placeholderUserId,
            chatId: chat.id,
            role: .user,
            content: content,
            status: .completed,
            tokenCount: nil,
            attachments: [],
            createdAt: Date()
        )
        let assistant = MessageDTO(
            id: placeholderAssistantId,
            chatId: chat.id,
            role: .assistant,
            content: "",
            status: .streaming,
            tokenCount: nil,
            attachments: [],
            createdAt: Date()
        )
        messages.append(userMessage)
        messages.append(assistant)

        let attachments = pendingAttachments
        pendingAttachments.removeAll()

        var accumulatedContent = ""
        let stream = service.streamMessage(chatId: chat.id, content: content, attachments: attachments)
        do {
            for try await event in stream {
                switch event {
                case .start: break
                case .delta(let chunk):
                    accumulatedContent += chunk
                    updateLastAssistant { $0.content += chunk }
                case .toolUse: break
                case .done(let final):
                    let resolvedContent = final.content.isEmpty ? accumulatedContent : final.content
                    updateLastAssistant {
                        $0.content = resolvedContent
                        $0.status = .completed
                    }
                case .quota(let q):
                    quota = q
                case .error(let m):
                    errorMessage = m
                    updateLastAssistant {
                        $0.content = accumulatedContent
                        $0.status = .failed
                    }
                }
            }
        } catch let api as APIError {
            handleStreamError(api)
            updateLastAssistant {
                $0.content = accumulatedContent
                $0.status = .failed
            }
        } catch {
            errorMessage = error.localizedDescription
            updateLastAssistant {
                $0.content = accumulatedContent
                $0.status = .failed
            }
        }
    }

    private func updateLastAssistant(_ mutate: (inout MessageDTO) -> Void) {
        guard let idx = messages.lastIndex(where: { $0.role == .assistant }) else { return }
        var m = messages[idx]
        mutate(&m)
        messages[idx] = m
    }

    private func handleStreamError(_ api: APIError) {
        switch api {
        case .quotaExceeded:
            errorMessage = APIError.quotaExceeded.errorDescription
        case .llmUnavailable:
            errorMessage = APIError.llmUnavailable.errorDescription
        default:
            errorMessage = api.errorDescription
        }
    }

    func rename(to title: String) async {
        do {
            chat = try await service.renameChat(id: chat.id, title: title)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyParameters(_ params: UpdateChatParametersRequest) async {
        do {
            chat = try await service.updateParameters(id: chat.id, params: params)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
