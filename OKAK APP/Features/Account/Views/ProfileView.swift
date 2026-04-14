
import SwiftUI

struct ProfileView: View {
    @StateObject var vm: ProfileViewModel

    var body: some View {
        Form {
            Section("Профиль") {
                TextField("Имя", text: $vm.displayName)
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
            Section("AI") {
                Toggle("Персонализация AI", isOn: $vm.aiPersonalization)
                Button("Сбросить персональные предпочтения AI", role: .destructive) {
                    Task { await vm.resetAIPersonalization() }
                }
            }
            if let err = vm.errorMessage {
                Section { Text(err).foregroundStyle(OKColor.danger) }
            }
            Section {
                Button("Сохранить") { Task { await vm.save() } }
            }
        }
        .navigationTitle("Профиль")
        .task { await vm.load() }
        .alert("Сохранено", isPresented: $vm.savedFlash) {
            Button("OK", role: .cancel) {}
        }
    }
}
