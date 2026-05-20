
import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var identifier: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var pendingVerificationEmail: String?

    let auth: AuthServiceType

    init(auth: AuthServiceType) {
        self.auth = auth
    }

    var canSubmit: Bool {
        !identifier.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        !isLoading
    }

    func submit() async {
        errorMessage = nil
        pendingVerificationEmail = nil
        guard canSubmit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await auth.login(identifier: identifier.trimmingCharacters(in: .whitespaces),
                                     password: password)
        } catch let api as APIError {
            switch api {
            case .forbidden(_) where api.requiresEmailVerification:
                let email = identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if AuthValidation.isValidEmail(email) {
                    pendingVerificationEmail = email
                    await auth.markPendingVerification(email: email)
                }
                errorMessage = "Email не подтверждён. Завершите верификацию, чтобы войти."
            case .unauthorized, .validation:
                errorMessage = "Неверный логин или пароль"
            case .forbidden(_):
                errorMessage = "Неверный логин или пароль"
            default:
                errorMessage = api.errorDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
