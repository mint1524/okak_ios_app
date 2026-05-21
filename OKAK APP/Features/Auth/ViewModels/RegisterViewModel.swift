
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
    @Published var shouldOpenVerification: Bool = false

    let auth: AuthServiceType

    init(auth: AuthServiceType) {
        self.auth = auth
    }

    var canSubmit: Bool {
        !isLoading
    }

    func validate() {
        emailError = AuthValidation.isValidEmail(email) ? nil : "Введите корректный email"
        passwordError = AuthValidation.passwordIssue(password)
    }

    func submit() async {
        generalError = nil
        verificationCodeHint = nil
        shouldOpenVerification = false
        validate()
        guard AuthValidation.isValidEmail(email),
              AuthValidation.passwordIssue(password) == nil else {
            generalError = "Проверьте email и пароль"
            return
        }
        guard AuthValidation.isAdult(dateOfBirth) else {
            generalError = "Регистрация доступна пользователям от 14 лет"
            return
        }
        guard acceptedTerms else {
            generalError = "Нужно принять условия и политики OKAK"
            return
        }
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let resp = try await auth.register(email: email.lowercased(), password: password, dateOfBirth: dateOfBirth)
            verificationCodeHint = resp.verificationCodeDev
            shouldOpenVerification = true
        } catch let api as APIError {
            switch api {
            case .validation(let m):
                if m.contains("уже зарегистрирован") || m.contains("already registered") || m.contains("уже существует") {
                    generalError = "Аккаунт с таким email уже зарегистрирован. Подтвердите email или сбросьте пароль."
                    await auth.markPendingVerification(email: email.lowercased())
                    shouldOpenVerification = true
                } else {
                    generalError = m
                }
            case .server(let code, _) where code == 500:
                generalError = "Возможно, аккаунт уже создан. Попробуйте подтвердить email или войти."
                await auth.markPendingVerification(email: email.lowercased())
                shouldOpenVerification = true
            default:
                generalError = api.errorDescription
            }
        } catch {
            generalError = error.localizedDescription
        }
    }
}
