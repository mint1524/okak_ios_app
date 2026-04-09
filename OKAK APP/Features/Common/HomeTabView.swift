
import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var deps: AppDependencies
    @State private var selection: HomeTab = .chat

    enum HomeTab: Hashable { case chat, store, subscriptions, account }

    var body: some View {
        TabView(selection: $selection) {
            ChatListView(vm: ChatListViewModel(service: deps.chatService))
                .tabItem { Label("AI Chat", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(HomeTab.chat)

            StoreView(vm: StoreViewModel(
                catalog: deps.catalogService,
                orders: deps.ordersService,
                subscriptions: deps.subscriptionsService
            ))
                .tabItem { Label("Магазин", systemImage: "bag.fill") }
                .tag(HomeTab.store)

            ActiveSubscriptionsView(vm: ActiveSubscriptionsViewModel(service: deps.subscriptionsService))
                .tabItem { Label("Подписки", systemImage: "creditcard.fill") }
                .tag(HomeTab.subscriptions)

            AccountPlaceholderView()
                .tabItem { Label("Аккаунт", systemImage: "person.crop.circle.fill") }
                .tag(HomeTab.account)
        }
        .tint(OKColor.accent)
    }
}

struct AccountPlaceholderView: View {
    @EnvironmentObject var deps: AppDependencies
    var body: some View {
        NavigationStack {
            VStack(spacing: OKSpacing.m) {
                Text("Аккаунт").font(OKFont.title)
                Button("Выйти") {
                    Task { await deps.authService.logout() }
                }
                .buttonStyle(OKSecondaryButtonStyle())
                .frame(maxWidth: 240)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(OKColor.background.ignoresSafeArea())
            .navigationTitle("Аккаунт")
        }
    }
}
