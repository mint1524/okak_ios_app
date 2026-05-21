
import Foundation
import Combine

@MainActor
final class StoreViewModel: ObservableObject {
    @Published private(set) var items: [SubscriptionDTO] = []
    @Published var filter: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let catalog: CatalogServiceType
    let orders: OrdersServiceType
    let subscriptions: SubscriptionsServiceType

    init(catalog: CatalogServiceType, orders: OrdersServiceType, subscriptions: SubscriptionsServiceType) {
        self.catalog = catalog
        self.orders = orders
        self.subscriptions = subscriptions
    }

    var availableTypes: [String] {
        Array(Set(items.map { $0.type })).sorted()
    }

    var filteredItems: [SubscriptionDTO] {
        guard let filter else { return items }
        return items.filter { $0.type == filter }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await catalog.list(type: nil)
            items = Self.purchaseOptions(from: loaded)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func purchaseOptions(from subscriptions: [SubscriptionDTO]) -> [SubscriptionDTO] {
        var seen = Set<String>()
        return subscriptions
            .filter { $0.price > 0 }
            .filter { sub in
                let key = "\(sub.type.lowercased())|\(canonicalName(sub.name))"
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
