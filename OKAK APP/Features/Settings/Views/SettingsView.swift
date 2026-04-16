
import SwiftUI

struct SettingsView: View {
    @StateObject var vm: SettingsViewModel
    @EnvironmentObject var deps: AppDependencies
    @State private var showLogoutConfirm = false
    @State private var showTerms = false
    @State private var showPrivacy = false

    var body: some View {
        Form {
            Section("Внешний вид") {
                Picker("Язык", selection: $vm.language) {
                    Text("Русский").tag("ru")
                    Text("English").tag("en")
                }
                Picker("Тема", selection: $vm.theme) {
                    Text("Системная").tag("system")
                    Text("Светлая").tag("light")
                    Text("Тёмная").tag("dark")
                }
            }
            Section("Уведомления") {
                Toggle("Push-уведомления", isOn: $vm.notifications)
                Toggle("Аналитика", isOn: $vm.analytics)
            }
            Section("Сессии") {
                NavigationLink("Активные сессии") {
                    SessionsView(vm: SessionsViewModel(service: deps.sessionsService))
                }
            }
            Section("Документы") {
                Button("Пользовательское соглашение") { showTerms = true }
                Button("Политика конфиденциальности") { showPrivacy = true }
            }
            Section("Выход") {
                Button("Выйти из аккаунта", role: .destructive) {
                    showLogoutConfirm = true
                }
            }
            if let err = vm.errorMessage {
                Section { Text(err).foregroundStyle(OKColor.danger) }
            }
        }
        .navigationTitle("Настройки")
        .task { await vm.load() }
        .onChange(of: vm.theme) { _, _ in Task { await vm.save() } }
        .onChange(of: vm.language) { _, _ in Task { await vm.save() } }
        .onChange(of: vm.notifications) { _, _ in Task { await vm.save() } }
        .onChange(of: vm.analytics) { _, _ in Task { await vm.save() } }
        .alert("Выйти из аккаунта?", isPresented: $showLogoutConfirm) {
            Button("Выйти", role: .destructive) {
                Task { await deps.authService.logout() }
            }
            Button("Отмена", role: .cancel) {}
        }
        .sheet(isPresented: $showTerms) { LegalDocumentView(kind: .terms) }
        .sheet(isPresented: $showPrivacy) { LegalDocumentView(kind: .privacy) }
    }
}
