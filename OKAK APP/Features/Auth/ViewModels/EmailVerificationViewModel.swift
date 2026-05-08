
import Foundation
import Combine

@MainActor
final class EmailVerificationViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var resendCooldown: Int = 0

    let email: String
    let auth: AuthServiceType
    private var cooldownTask: Task<Void, Never>?

    init(email: String, auth: AuthServiceType) {
        self.email = email
        self.auth = auth
    }

    var canSubmit: Bool {
        code.count == 6 && code.allSatisfy(\.isNumber) && !isLoading
    }

    func submit() async {
        errorMessage = nil
        guard canSubmit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await auth.verifyEmail(email: email, code: code)
        } catch let api as APIError {
            if case .validation(let m) = api {
                errorMessage = m
            } else if case .notFound = api {
                errorMessage = "Неверный код подтверждения"
            } else {
                errorMessage = api.errorDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resend() async {
        guard resendCooldown == 0 else { return }
        errorMessage = nil
        do {
            try await auth.resendVerification(email: email)
            startCooldown()
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startCooldown() {
        cooldownTask?.cancel()
        resendCooldown = 60
        cooldownTask = Task { [weak self] in
            while let value = self?.resendCooldown, value > 0 {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { self?.resendCooldown -= 1 }
            }
        }
    }
}
