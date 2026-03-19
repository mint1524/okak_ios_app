
import Foundation

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

    private let auth: AuthServiceType

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
            if case .validation(let m) = api {
                generalError = m
            } else {
                generalError = api.errorDescription
            }
        } catch {
            generalError = error.localizedDescription
        }
    }
}
