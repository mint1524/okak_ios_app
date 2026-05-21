
import Foundation
import Combine

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
            items = Self.deduplicated(try await service.active())
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
        items = Self.deduplicated(items)
    }

    private static func deduplicated(_ subscriptions: [UserSubscriptionDTO]) -> [UserSubscriptionDTO] {
        var seen = Set<String>()
        return subscriptions.filter { sub in
            guard sub.status == "active" else { return false }
            let key = canonicalName(sub.name)
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }

    private static func canonicalName(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .lowercased()
    }
}
