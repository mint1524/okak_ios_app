
import SwiftUI

struct SubscriptionDetailView: View {
    let subscription: SubscriptionDTO
    let orders: OrdersServiceType
    @State private var showPayment = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OKSpacing.l) {
                    Text(subscription.name).font(OKFont.title)
                    Text(priceLabel)
                        .font(OKFont.title2)
                        .foregroundStyle(OKColor.accent)
                    Text(subscription.description)
                        .font(OKFont.body)
                        .foregroundStyle(OKColor.textPrimary)
                    Divider()
                    VStack(alignment: .leading, spacing: OKSpacing.s) {
                        Text("Что входит").font(OKFont.bodyBold)
                        ForEach(subscription.features, id: \.self) { f in
                            Label(f, systemImage: "checkmark.circle.fill")
                                .foregroundStyle(OKColor.success)
                                .font(OKFont.callout)
                        }
                    }
                    Divider()
                    VStack(alignment: .leading, spacing: OKSpacing.xs) {
                        Label("\(subscription.durationDays) дней", systemImage: "calendar")
                        Label("\(subscription.quotaLimit) AI-запросов", systemImage: "bolt.fill")
                        Label("Тип: \(subscription.type.capitalized)", systemImage: "tag.fill")
                    }
                    .font(OKFont.callout)
                    .foregroundStyle(OKColor.textSecondary)
                }
                .padding(OKSpacing.l)
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    showPayment = true
                } label: { Text("Оформить покупку") }
                .buttonStyle(OKPrimaryButtonStyle())
                .padding(OKSpacing.l)
                .background(OKColor.background)
            }
            .navigationTitle("Подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .sheet(isPresented: $showPayment) {
                MockPaymentView(vm: PurchaseViewModel(subscription: subscription, orders: orders))
            }
        }
    }

    private var priceLabel: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        return formatter.string(from: subscription.price as NSDecimalNumber) ?? "\(subscription.price)"
    }
}
