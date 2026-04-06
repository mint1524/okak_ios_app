
import SwiftUI

struct OrdersHistoryView: View {
    @StateObject var vm: OrdersHistoryViewModel

    var body: some View {
        List {
            if vm.orders.isEmpty {
                Text("История заказов пуста")
                    .foregroundStyle(OKColor.textSecondary)
            }
            ForEach(vm.orders) { order in
                VStack(alignment: .leading, spacing: OKSpacing.xs) {
                    HStack {
                        Text(order.subscriptionName).font(OKFont.bodyBold)
                        Spacer()
                        Text(priceLabel(order))
                            .font(OKFont.bodyBold)
                    }
                    HStack(spacing: OKSpacing.s) {
                        Text(order.createdAt, style: .date)
                        Text("•")
                        Text(order.status.capitalized)
                    }
                    .font(OKFont.caption)
                    .foregroundStyle(statusColor(order.status))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("История заказов")
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
    }

    private func priceLabel(_ order: OrderDTO) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = order.currency
        return formatter.string(from: order.amount as NSDecimalNumber) ?? "\(order.amount)"
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "paid", "completed": return OKColor.success
        case "failed", "cancelled": return OKColor.danger
        default: return OKColor.textSecondary
        }
    }
}
