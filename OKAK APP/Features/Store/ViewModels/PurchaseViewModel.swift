
import Foundation
import Combine

@MainActor
final class PurchaseViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case creating
        case ready(CreateOrderResponse)
        case processing
        case success(OrderDTO)
        case failed(String)
    }

    @Published private(set) var phase: Phase = .idle
    let subscription: SubscriptionDTO
    private let orders: OrdersServiceType

    init(subscription: SubscriptionDTO, orders: OrdersServiceType) {
        self.subscription = subscription
        self.orders = orders
    }

    func start() async {
        phase = .creating
        do {
            let resp = try await orders.create(subscriptionId: subscription.id)
            phase = .ready(resp)
        } catch let api as APIError {
            phase = .failed(api.errorDescription ?? "Не удалось создать заказ")
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func confirm(outcome: String) async {
        guard case .ready(let prepared) = phase else { return }
        phase = .processing
        do {
            let payment = try await orders.confirmMockPayment(
                providerPaymentId: prepared.payment.providerPaymentId,
                outcome: outcome
            )
            if payment.status == "success" {
                let updatedOrder = try await orders.get(id: prepared.order.id)
                phase = .success(updatedOrder)
            } else if payment.status == "cancelled" {
                phase = .failed("Оплата отменена")
            } else {
                phase = .failed("Оплата не прошла. Попробуйте ещё раз.")
            }
        } catch let api as APIError {
            phase = .failed(api.errorDescription ?? "Ошибка оплаты")
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
