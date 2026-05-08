
import Foundation
import Combine

@MainActor
final class OrdersHistoryViewModel: ObservableObject {
    @Published private(set) var orders: [OrderDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: OrdersServiceType

    init(service: OrdersServiceType) {
        self.service = service
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            orders = try await service.list()
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
