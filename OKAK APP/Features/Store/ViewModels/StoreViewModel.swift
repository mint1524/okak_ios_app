
import Foundation

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
            items = try await catalog.list(type: nil)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
