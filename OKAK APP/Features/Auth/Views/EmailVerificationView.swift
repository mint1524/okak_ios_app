
import SwiftUI

struct EmailVerificationView: View {
    @StateObject var vm: EmailVerificationViewModel
    var devCodeHint: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OKSpacing.l) {
                Text("Подтверждение email")
                    .font(OKFont.title)
                Text("Мы отправили шестизначный код на \(vm.email).")
                    .font(OKFont.footnote)
                    .foregroundStyle(OKColor.textSecondary)

                if let hint = devCodeHint {
                    Text("Dev-режим: код — \(hint)")
                        .font(OKFont.mono)
                        .foregroundStyle(OKColor.warning)
                        .padding(OKSpacing.s)
                        .background(
                            RoundedRectangle(cornerRadius: OKRadius.s)
                                .fill(OKColor.warning.opacity(0.1))
                        )
                }

                TextField("Код", text: $vm.code)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(OKTextFieldStyle())
                    .onChange(of: vm.code) { _, newValue in
                        let filtered = newValue.filter(\.isNumber)
                        if filtered != newValue { vm.code = filtered }
                        if vm.code.count > 6 { vm.code = String(vm.code.prefix(6)) }
                    }

                if let err = vm.errorMessage {
                    Text(err).font(OKFont.footnote).foregroundStyle(OKColor.danger)
                }

                Button { Task { await vm.submit() } } label: {
                    Text("Подтвердить")
                }
                .buttonStyle(OKPrimaryButtonStyle(loading: vm.isLoading))
                .disabled(!vm.canSubmit)

                Button { Task { await vm.resend() } } label: {
                    if vm.resendCooldown > 0 {
                        Text("Отправить код ещё раз через \(vm.resendCooldown) с")
                    } else {
                        Text("Отправить код ещё раз")
                    }
                }
                .buttonStyle(.plain)
                .font(OKFont.footnote)
                .foregroundStyle(vm.resendCooldown > 0 ? OKColor.textSecondary : OKColor.accent)
                .disabled(vm.resendCooldown > 0)
            }
            .padding(OKSpacing.l)
        }
        .background(OKColor.background.ignoresSafeArea())
    }
}
