
import SwiftUI

struct PasswordResetView: View {
    @StateObject var vm: PasswordResetViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OKSpacing.l) {
                Text("Сброс пароля")
                    .font(OKFont.title)
                Text("Введите email, привязанный к аккаунту. Мы пришлём ссылку для смены пароля.")
                    .font(OKFont.footnote)
                    .foregroundStyle(OKColor.textSecondary)
                TextField("Email", text: $vm.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textFieldStyle(OKTextFieldStyle())
                if let err = vm.errorMessage {
                    Text(err).font(OKFont.footnote).foregroundStyle(OKColor.danger)
                }
                if vm.didSend {
                    Label("Ссылка отправлена", systemImage: "checkmark.circle.fill")
                        .font(OKFont.footnote)
                        .foregroundStyle(OKColor.success)
                }
                Button {
                    Task { await vm.submit() }
                } label: { Text("Отправить ссылку") }
                .buttonStyle(OKPrimaryButtonStyle(loading: vm.isLoading))
                .disabled(!vm.canSubmit)
            }
            .padding(OKSpacing.l)
        }
        .background(OKColor.background.ignoresSafeArea())
    }
}
