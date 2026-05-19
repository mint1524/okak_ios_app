
import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @Published var acceptedTerms: Bool = false
    @Published var isLoading: Bool = false
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var generalError: String?
    @Published var verificationCodeHint: String?

    let auth: AuthServiceType

    init(auth: AuthServiceType) {
        self.auth = auth
    }

    var canSubmit: Bool {
        AuthValidation.isValidEmail(email) &&
        AuthValidation.passwordIssue(password) == nil &&
        AuthValidation.isAdult(dateOfBirth) &&
        acceptedTerms &&
        !isLoading
    }

    func validate() {
        emailError = AuthValidation.isValidEmail(email) ? nil : "Введите корректный email"
        passwordError = AuthValidation.passwordIssue(password)
    }

    func submit() async {
        generalError = nil
        verificationCodeHint = nil
        validate()
        guard canSubmit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let resp = try await auth.register(email: email.lowercased(), password: password, dateOfBirth: dateOfBirth)
            verificationCodeHint = resp.verificationCodeDev
        } catch let api as APIError {
            switch api {
            case .validation(let m):
                if m.contains("уже зарегистрирован") || m.contains("already registered") || m.contains("уже существует") {
                    generalError = "Аккаунт с таким email уже зарегистрирован. Подтвердите email или сбросьте пароль."
                } else {
                    generalError = m
                }
            case .server(let code, _) where code == 500:
                generalError = "Возможно, аккаунт уже создан. Попробуйте подтвердить email или войти."
            default:
                generalError = api.errorDescription
            }
        } catch {
            generalError = error.localizedDescription
        }
    }
}
