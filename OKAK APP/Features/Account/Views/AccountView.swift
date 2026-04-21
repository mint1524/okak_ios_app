
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var deps: AppDependencies

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Профиль") {
                        ProfileView(vm: ProfileViewModel(service: deps.profileService))
                    }
                    NavigationLink("Активные подписки") {
                        ActiveSubscriptionsView(vm: ActiveSubscriptionsViewModel(service: deps.subscriptionsService))
                    }
                    NavigationLink("История заказов") {
                        OrdersHistoryView(vm: OrdersHistoryViewModel(service: deps.ordersService))
                    }
                }
                Section {
                    NavigationLink("Настройки") {
                        SettingsView(vm: SettingsViewModel(service: deps.settingsService))
                    }
                }
            }
            .navigationTitle("Аккаунт")
        }
    }
}
