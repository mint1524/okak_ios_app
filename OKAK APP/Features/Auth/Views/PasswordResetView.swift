
import SwiftUI

struct PasswordResetView: View {
    @StateObject var vm: PasswordResetViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OKSpacing.l) {
                Text("Сброс пароля")
                    .font(OKFont.title)

                switch vm.step {
                case .requestEmail:
                    requestEmailStep
                case .enterCode:
                    enterCodeStep
                case .done:
                    doneStep
                }
            }
            .padding(OKSpacing.l)
        }
        .background(OKColor.background.ignoresSafeArea())
    }

    @ViewBuilder
    private var requestEmailStep: some View {
        Text("Введите email, привязанный к аккаунту. Мы пришлём 6-значный код для сброса пароля.")
            .font(OKFont.footnote)
            .foregroundStyle(OKColor.textSecondary)
        TextField("Email", text: $vm.email)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textFieldStyle(OKTextFieldStyle())
        messages
        Button {
            Task { await vm.requestCode() }
        } label: { Text("Получить код") }
        .buttonStyle(OKPrimaryButtonStyle(loading: vm.isLoading))
        .disabled(!vm.canRequestEmail)
    }

    @ViewBuilder
    private var enterCodeStep: some View {
        Text("Введите 6-значный код, отправленный на \(vm.email), и задайте новый пароль.")
            .font(OKFont.footnote)
            .foregroundStyle(OKColor.textSecondary)
        TextField("Код из письма", text: $vm.code)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .textFieldStyle(OKTextFieldStyle())
        SecureField("Новый пароль", text: $vm.newPassword)
            .textContentType(.newPassword)
            .textFieldStyle(OKTextFieldStyle())
        SecureField("Повторите пароль", text: $vm.confirmPassword)
            .textContentType(.newPassword)
            .textFieldStyle(OKTextFieldStyle())
        if !vm.newPassword.isEmpty, let issue = AuthValidation.passwordIssue(vm.newPassword) {
            Text(issue).font(OKFont.footnote).foregroundStyle(OKColor.danger)
        }
        if !vm.confirmPassword.isEmpty, vm.confirmPassword != vm.newPassword {
            Text("Пароли не совпадают").font(OKFont.footnote).foregroundStyle(OKColor.danger)
        }
        messages
        Button {
            Task { await vm.confirm() }
        } label: { Text("Сменить пароль") }
        .buttonStyle(OKPrimaryButtonStyle(loading: vm.isLoading))
        .disabled(!vm.canConfirm)

        Button {
            Task { await vm.resendCode() }
        } label: {
            Text("Отправить код ещё раз")
                .font(OKFont.footnote)
                .foregroundStyle(OKColor.accent)
        }
        .disabled(vm.isLoading)
    }

    @ViewBuilder
    private var doneStep: some View {
        Label("Пароль обновлён. Войдите с новым паролем.", systemImage: "checkmark.circle.fill")
            .font(OKFont.body)
            .foregroundStyle(OKColor.success)
        Button {
            dismiss()
        } label: { Text("Вернуться ко входу") }
        .buttonStyle(OKPrimaryButtonStyle())
    }

    @ViewBuilder
    private var messages: some View {
        if let info = vm.infoMessage {
            Text(info).font(OKFont.footnote).foregroundStyle(OKColor.textSecondary)
        }
        if let err = vm.errorMessage {
            Text(err).font(OKFont.footnote).foregroundStyle(OKColor.danger)
        }
    }
}
