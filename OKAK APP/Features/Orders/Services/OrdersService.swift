
import Foundation

protocol OrdersServiceType: AnyObject, Sendable {
    func list() async throws -> [OrderDTO]
    func get(id: String) async throws -> OrderDTO
    func create(subscriptionId: String) async throws -> CreateOrderResponse
    func confirmMockPayment(providerPaymentId: String, outcome: String) async throws -> MockPaymentDTO
}

final class OrdersService: OrdersServiceType, @unchecked Sendable {
    private let api: APIClientType
    init(api: APIClientType) { self.api = api }

    func list() async throws -> [OrderDTO] {
        let endpoint = APIEndpoint(method: .get, path: "orders")
        return try await api.send(endpoint, as: OrdersListResponse.self).items
    }

    func get(id: String) async throws -> OrderDTO {
        let endpoint = APIEndpoint(method: .get, path: "orders/\(id)")
        return try await api.send(endpoint, as: OrderDTO.self)
    }

    func create(subscriptionId: String) async throws -> CreateOrderResponse {
        var endpoint = APIEndpoint(method: .post, path: "orders")
        endpoint.body = try APIEndpoint.jsonBody(CreateOrderRequest(subscriptionId: subscriptionId))
        return try await api.send(endpoint, as: CreateOrderResponse.self)
    }

    func confirmMockPayment(providerPaymentId: String, outcome: String) async throws -> MockPaymentDTO {
        var endpoint = APIEndpoint(method: .post, path: "payments/mock/confirm")
        endpoint.body = try APIEndpoint.jsonBody(MockPaymentConfirmRequest(providerPaymentId: providerPaymentId, outcome: outcome))
        return try await api.send(endpoint, as: MockPaymentDTO.self)
    }
}
