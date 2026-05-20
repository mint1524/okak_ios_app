
import SwiftUI

struct RegisterView: View {
    @StateObject var vm: RegisterViewModel
    @State private var pushVerify = false
    @State private var showTerms = false
    @State private var showPrivacy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OKSpacing.l) {
                Text("Создать аккаунт")
                    .font(OKFont.title)
                Text("Понадобится email, пароль и дата рождения.")
                    .font(OKFont.footnote)
                    .foregroundStyle(OKColor.textSecondary)

                fields

                DatePicker(
                    "Дата рождения",
                    selection: $vm.dateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding(.vertical, OKSpacing.s)

                terms

                if let err = vm.generalError {
                    Text(err)
                        .font(OKFont.footnote)
                        .foregroundStyle(OKColor.danger)
                }

                Button {
                    Task {
                        await vm.submit()
                        if vm.shouldOpenVerification {
                            pushVerify = true
                        }
                    }
                } label: { Text("Создать аккаунт") }
                .buttonStyle(OKPrimaryButtonStyle(loading: vm.isLoading))
                .disabled(!vm.canSubmit)
            }
            .padding(OKSpacing.l)
        }
        .background(OKColor.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationDestination(isPresented: $pushVerify) {
            EmailVerificationView(
                vm: EmailVerificationViewModel(email: vm.email.lowercased(), auth: vm.auth),
                devCodeHint: vm.verificationCodeHint
            )
        }
        .sheet(isPresented: $showTerms) { LegalDocumentView(kind: .terms) }
        .sheet(isPresented: $showPrivacy) { LegalDocumentView(kind: .privacy) }
    }

    private var fields: some View {
        VStack(spacing: OKSpacing.m) {
            VStack(alignment: .leading, spacing: OKSpacing.xs) {
                TextField("Email", text: $vm.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textFieldStyle(OKTextFieldStyle())
                    .onChange(of: vm.email) { _, _ in vm.emailError = nil }
                if let e = vm.emailError {
                    Text(e).font(OKFont.caption).foregroundStyle(OKColor.danger)
                }
            }
            VStack(alignment: .leading, spacing: OKSpacing.xs) {
                SecureField("Пароль (от 10 символов)", text: $vm.password)
                    .textFieldStyle(OKTextFieldStyle())
                    .onChange(of: vm.password) { _, _ in vm.passwordError = nil }
                if let e = vm.passwordError {
                    Text(e).font(OKFont.caption).foregroundStyle(OKColor.danger)
                }
            }
        }
    }

    private var terms: some View {
        VStack(alignment: .leading, spacing: OKSpacing.s) {
            Toggle(isOn: $vm.acceptedTerms) {
                Text("Принимаю условия и политики OKAK")
                    .font(OKFont.footnote)
            }
            HStack(spacing: OKSpacing.m) {
                Button("Пользовательское соглашение") { showTerms = true }
                    .buttonStyle(.plain)
                    .font(OKFont.caption)
                    .foregroundStyle(OKColor.accent)
                Button("Политика конфиденциальности") { showPrivacy = true }
                    .buttonStyle(.plain)
                    .font(OKFont.caption)
                    .foregroundStyle(OKColor.accent)
            }
        }
    }
}
