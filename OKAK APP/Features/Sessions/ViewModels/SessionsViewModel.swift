
import Foundation

@MainActor
final class SessionsViewModel: ObservableObject {
    @Published private(set) var sessions: [SessionDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: SessionsServiceType
    init(service: SessionsServiceType) { self.service = service }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await service.list()
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func revoke(_ session: SessionDTO) async {
        guard !session.isCurrent else { return }
        do {
            try await service.revoke(id: session.id)
            sessions.removeAll { $0.id == session.id }
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
