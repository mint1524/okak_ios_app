
import Foundation

@MainActor
final class ActiveSubscriptionsViewModel: ObservableObject {
    @Published private(set) var items: [UserSubscriptionDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let service: SubscriptionsServiceType
    init(service: SubscriptionsServiceType) {
        self.service = service
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await service.active()
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancel(_ sub: UserSubscriptionDTO) async {
        do {
            let updated = try await service.cancel(id: sub.id)
            replace(updated)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func renew(_ sub: UserSubscriptionDTO) async {
        do {
            let updated = try await service.renew(id: sub.id)
            replace(updated)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func replace(_ sub: UserSubscriptionDTO) {
        if let idx = items.firstIndex(where: { $0.id == sub.id }) {
            items[idx] = sub
        } else {
            items.append(sub)
        }
    }
}
