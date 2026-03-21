
import SwiftUI

struct LoginView: View {
    @StateObject var vm: LoginViewModel
    @State private var showRegister = false
    @State private var showReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: OKSpacing.l) {
                    header
                    fields
                    submitButton
                    if let err = vm.errorMessage {
                        Text(err)
                            .font(OKFont.footnote)
                            .foregroundStyle(OKColor.danger)
                            .multilineTextAlignment(.center)
                    }
                    Button("Сброс пароля") { showReset = true }
                        .buttonStyle(.plain)
                        .font(OKFont.footnote)
                        .foregroundStyle(OKColor.accent)
                    Spacer(minLength: OKSpacing.xl)
                    Button {
                        showRegister = true
                    } label: {
                        Text("Создать аккаунт")
                    }
                    .buttonStyle(OKSecondaryButtonStyle())
                }
                .padding(.horizontal, OKSpacing.l)
                .padding(.top, OKSpacing.xxl)
            }
            .background(OKColor.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(vm: RegisterViewModel(auth: vm.auth))
            }
            .navigationDestination(isPresented: $showReset) {
                PasswordResetView(vm: PasswordResetViewModel(auth: vm.auth))
            }
        }
    }

    private var header: some View {
        VStack(spacing: OKSpacing.xs) {
            Text("OKAK")
                .font(OKFont.brand)
                .foregroundStyle(OKColor.accent)
            Text("Войдите, чтобы начать общение с AI")
                .font(OKFont.footnote)
                .foregroundStyle(OKColor.textSecondary)
        }
        .padding(.bottom, OKSpacing.l)
    }

    private var fields: some View {
        VStack(spacing: OKSpacing.m) {
            TextField("Email или username", text: $vm.identifier)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textFieldStyle(OKTextFieldStyle())
            SecureField("Пароль", text: $vm.password)
                .textFieldStyle(OKTextFieldStyle())
        }
    }

    private var submitButton: some View {
        Button {
            Task { await vm.submit() }
        } label: {
            Text("Войти")
        }
        .buttonStyle(OKPrimaryButtonStyle(loading: vm.isLoading))
        .disabled(!vm.canSubmit)
    }
}


