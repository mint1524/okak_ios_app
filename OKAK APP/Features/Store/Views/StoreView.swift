
import SwiftUI

struct StoreView: View {
    @StateObject var vm: StoreViewModel
    @State private var presented: SubscriptionDTO?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Магазин")
                .task { await vm.refresh() }
                .refreshable { await vm.refresh() }
                .sheet(item: $presented) { sub in
                    SubscriptionDetailView(subscription: sub, orders: vm.orders)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.items.isEmpty {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.items.isEmpty {
            EmptyStateView(text: "Каталог пока пуст")
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: OKSpacing.l) {
                    filterStrip
                    LazyVStack(spacing: OKSpacing.m) {
                        ForEach(vm.filteredItems) { sub in
                            SubscriptionCardView(subscription: sub)
                                .onTapGesture { presented = sub }
                        }
                    }
                }
                .padding(.horizontal, OKSpacing.l)
                .padding(.vertical, OKSpacing.m)
            }
        }
    }

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: OKSpacing.s) {
                FilterChip(title: "Все", isSelected: vm.filter == nil) { vm.filter = nil }
                ForEach(vm.availableTypes, id: \.self) { t in
                    FilterChip(title: t.capitalized, isSelected: vm.filter == t) { vm.filter = t }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(OKFont.footnote)
                .padding(.horizontal, OKSpacing.m)
                .padding(.vertical, OKSpacing.s)
                .background(
                    Capsule().fill(isSelected ? OKColor.accent : OKColor.surface)
                )
                .foregroundStyle(isSelected ? Color.white : OKColor.textPrimary)
        }
        .buttonStyle(.plain)
    }
}

struct SubscriptionCardView: View {
    let subscription: SubscriptionDTO
    var body: some View {
        VStack(alignment: .leading, spacing: OKSpacing.s) {
            HStack {
                Text(subscription.name).font(OKFont.title3)
                Spacer()
                Text(priceLabel)
                    .font(OKFont.bodyBold)
                    .foregroundStyle(OKColor.accent)
            }
            Text(subscription.description)
                .font(OKFont.footnote)
                .foregroundStyle(OKColor.textSecondary)
                .lineLimit(3)
            HStack(spacing: OKSpacing.s) {
                Label("\(subscription.durationDays) дн.", systemImage: "calendar")
                Label("\(subscription.quotaLimit) запросов", systemImage: "bolt.fill")
            }
            .font(OKFont.caption)
            .foregroundStyle(OKColor.textTertiary)
        }
        .padding(OKSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: OKRadius.l)
                .fill(OKColor.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: OKRadius.l)
                .stroke(OKColor.separator, lineWidth: 1)
        )
    }

    private var priceLabel: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        return formatter.string(from: subscription.price as NSDecimalNumber) ?? "\(subscription.price) \(subscription.currency)"
    }
}

struct EmptyStateView: View {
    let text: String
    var body: some View {
        VStack {
            Image(systemName: "tray").resizable().scaledToFit().frame(width: 48, height: 48)
                .foregroundStyle(OKColor.textTertiary)
            Text(text).font(OKFont.footnote).foregroundStyle(OKColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
