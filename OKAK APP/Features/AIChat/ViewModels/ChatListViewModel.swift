
import Foundation
import Combine

@MainActor
final class ChatListViewModel: ObservableObject {
    @Published private(set) var chats: [ChatDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var quota: QuotaDTO?

    let service: ChatServiceType

    init(service: ChatServiceType) {
        self.service = service
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        async let chatsAsync = try? service.listChats()
        async let quotaAsync = try? service.currentQuota()
        let (loadedChats, loadedQuota) = await (chatsAsync, quotaAsync)
        if let loadedChats { chats = loadedChats }
        if let loadedQuota { quota = loadedQuota }
    }

    func createChat() async -> ChatDTO? {
        do {
            let chat = try await service.createChat(title: nil)
            chats.insert(chat, at: 0)
            return chat
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        return nil
    }

    func delete(_ chat: ChatDTO) async {
        do {
            try await service.deleteChat(id: chat.id)
            chats.removeAll { $0.id == chat.id }
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
