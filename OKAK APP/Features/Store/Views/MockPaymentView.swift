
import SwiftUI

struct MockPaymentView: View {
    @StateObject var vm: PurchaseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: OKSpacing.l) {
                Text("Оплата (mock)")
                    .font(OKFont.title2)
                Text(vm.subscription.name)
                    .font(OKFont.bodyBold)
                Text(amountLabel)
                    .font(OKFont.title)
                    .foregroundStyle(OKColor.accent)
                phaseView
                Spacer()
            }
            .padding(OKSpacing.l)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(OKColor.background.ignoresSafeArea())
            .task {
                if case .idle = vm.phase {
                    await vm.start()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }

    private var amountLabel: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = vm.subscription.currency
        return formatter.string(from: vm.subscription.price as NSDecimalNumber) ?? "\(vm.subscription.price)"
    }

    @ViewBuilder
    private var phaseView: some View {
        switch vm.phase {
        case .idle, .creating:
            ProgressView("Создаём заказ…")
        case .ready:
            VStack(spacing: OKSpacing.m) {
                Button("Подтвердить оплату") {
                    Task { await vm.confirm(outcome: "success") }
                }
                .buttonStyle(OKPrimaryButtonStyle())
                Button("Имитация ошибки оплаты") {
                    Task { await vm.confirm(outcome: "failed") }
                }
                .buttonStyle(OKSecondaryButtonStyle())
                Button("Отмена") {
                    Task { await vm.confirm(outcome: "cancelled") }
                }
                .buttonStyle(.plain)
                .foregroundStyle(OKColor.textSecondary)
            }
        case .processing:
            ProgressView("Обрабатываем платёж…")
        case .success(let order):
            VStack(spacing: OKSpacing.m) {
                Image(systemName: "checkmark.seal.fill").resizable().frame(width: 64, height: 64)
                    .foregroundStyle(OKColor.success)
                Text("Заказ #\(order.id.prefix(6)) оплачен")
                    .font(OKFont.bodyBold)
                Text("Подписка \(order.subscriptionName) активирована.")
                    .font(OKFont.footnote)
                    .foregroundStyle(OKColor.textSecondary)
                Button("Готово") { dismiss() }
                    .buttonStyle(OKPrimaryButtonStyle())
            }
        case .failed(let message):
            VStack(spacing: OKSpacing.m) {
                Image(systemName: "xmark.octagon.fill").resizable().frame(width: 56, height: 56)
                    .foregroundStyle(OKColor.danger)
                Text(message)
                    .font(OKFont.footnote)
                    .foregroundStyle(OKColor.danger)
                    .multilineTextAlignment(.center)
                Button("Попробовать снова") {
                    Task { await vm.start() }
                }
                .buttonStyle(OKSecondaryButtonStyle())
            }
        }
    }
}
