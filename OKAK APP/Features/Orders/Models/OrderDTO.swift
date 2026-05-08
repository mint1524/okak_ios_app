
import Foundation

struct OrderDTO: Identifiable, Decodable, Hashable {
    let id: String
    let subscriptionId: String
    let subscriptionName: String
    let amount: Decimal
    let currency: String
    let status: String
    let createdAt: Date
    let paymentId: String?
    let paymentStatus: String?

    enum CodingKeys: String, CodingKey {
        case id
        case subscriptionId = "subscription_id"
        case subscriptionName = "subscription_name"
        case amount
        case currency
        case status
        case createdAt = "created_at"
        case paymentId = "payment_id"
        case paymentStatus = "payment_status"
    }
}

struct OrdersListResponse: Decodable {
    let items: [OrderDTO]
}

struct CreateOrderRequest: Encodable {
    let subscriptionId: String

    enum CodingKeys: String, CodingKey { case subscriptionId = "subscription_id" }
}

struct CreateOrderResponse: Decodable, Equatable {
    let order: OrderDTO
    let payment: MockPaymentDTO
}

struct MockPaymentDTO: Decodable, Hashable {
    let id: String
    let providerPaymentId: String
    let amount: Decimal
    let currency: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case providerPaymentId = "provider_payment_id"
        case amount
        case currency
        case status
    }
}

struct MockPaymentConfirmRequest: Encodable {
    let providerPaymentId: String
    let outcome: String

    enum CodingKeys: String, CodingKey {
        case providerPaymentId = "provider_payment_id"
        case outcome
    }
}
