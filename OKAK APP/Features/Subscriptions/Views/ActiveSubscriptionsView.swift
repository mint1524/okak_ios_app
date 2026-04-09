
import SwiftUI

struct ActiveSubscriptionsView: View {
    @StateObject var vm: ActiveSubscriptionsViewModel
    @State private var ordersVM: OrdersHistoryViewModel?
    @EnvironmentObject var deps: AppDependencies

    var body: some View {
        NavigationStack {
            List {
                Section("Активные") {
                    if vm.items.isEmpty {
                        Text("Нет активных подписок")
                            .foregroundStyle(OKColor.textSecondary)
                    }
                    ForEach(vm.items) { sub in
                        UserSubscriptionRow(sub: sub,
                                            onCancel: { Task { await vm.cancel(sub) } },
                                            onRenew: { Task { await vm.renew(sub) } })
                    }
                }
                Section {
                    NavigationLink("История заказов") {
                        OrdersHistoryView(vm: OrdersHistoryViewModel(service: deps.ordersService))
                    }
                }
                if let err = vm.errorMessage {
                    Section {
                        Text(err).foregroundStyle(OKColor.danger).font(OKFont.footnote)
                    }
                }
            }
            .navigationTitle("Подписки")
            .task { await vm.refresh() }
            .refreshable { await vm.refresh() }
        }
    }
}

struct UserSubscriptionRow: View {
    let sub: UserSubscriptionDTO
    let onCancel: () -> Void
    let onRenew: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: OKSpacing.s) {
            HStack {
                Text(sub.name).font(OKFont.bodyBold)
                Spacer()
                statusBadge
            }
            Text("До \(sub.endDate, style: .date)")
                .font(OKFont.caption)
                .foregroundStyle(OKColor.textSecondary)
            HStack(spacing: OKSpacing.s) {
                if sub.status == "active" {
                    Button("Отменить", action: onCancel)
                        .buttonStyle(.borderedProminent)
                        .tint(OKColor.danger.opacity(0.85))
                } else {
                    Button("Продлить", action: onRenew)
                        .buttonStyle(.borderedProminent)
                        .tint(OKColor.accent)
                }
            }
            .font(OKFont.footnote)
        }
        .padding(.vertical, OKSpacing.xs)
    }

    private var statusBadge: some View {
        Text(sub.status.capitalized)
            .font(OKFont.caption)
            .padding(.horizontal, OKSpacing.s)
            .padding(.vertical, OKSpacing.xxs)
            .background(Capsule().fill(badgeColor.opacity(0.15)))
            .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        switch sub.status {
        case "active": return OKColor.success
        case "cancelled", "expired": return OKColor.danger
        default: return OKColor.warning
        }
    }
}
