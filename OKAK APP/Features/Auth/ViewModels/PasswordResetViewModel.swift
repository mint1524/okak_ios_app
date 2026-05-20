
import Foundation
import Combine

@MainActor
final class PasswordResetViewModel: ObservableObject {
    enum Step { case requestEmail, enterCode, done }

    @Published var step: Step = .requestEmail
    @Published var email: String = ""
    @Published var code: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    let auth: AuthServiceType

    init(auth: AuthServiceType) {
        self.auth = auth
    }

    var canRequestEmail: Bool {
        AuthValidation.isValidEmail(email) && !isLoading
    }

    var canConfirm: Bool {
        code.count == 6 && code.allSatisfy(\.isNumber)
            && AuthValidation.isValidPassword(newPassword)
            && newPassword == confirmPassword
            && !isLoading
    }

    func requestCode() async {
        errorMessage = nil
        infoMessage = nil
        guard canRequestEmail else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.requestPasswordReset(email: email.lowercased())
            step = .enterCode
            infoMessage = "Если адрес зарегистрирован, на него отправлен код."
        } catch let api as APIError {
            switch api {
            case .forbidden:
                errorMessage = "Доступ запрещён. Проверьте email или обратитесь в поддержку."
            case .server(let code, _) where code == 500:
                infoMessage = "Если адрес зарегистрирован, код мог быть отправлен."
                step = .enterCode
            default:
                errorMessage = api.errorDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resendCode() async {
        errorMessage = nil
        infoMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.requestPasswordReset(email: email.lowercased())
            infoMessage = "Новый код отправлен."
        } catch let api as APIError {
            switch api {
            case .forbidden:
                errorMessage = "Доступ запрещён. Проверьте email или обратитесь в поддержку."
            case .server(let code, _) where code == 500:
                infoMessage = "Новый код мог быть отправлен."
            default:
                errorMessage = api.errorDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirm() async {
        errorMessage = nil
        infoMessage = nil
        guard canConfirm else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.confirmPasswordReset(
                email: email.lowercased(),
                code: code,
                newPassword: newPassword
            )
            step = .done
        } catch let api as APIError {
            switch api {
            case .forbidden:
                errorMessage = "Код недействителен или истёк. Запросите новый."
            case .validation(let m):
                errorMessage = m
            case .server(let code, _) where code == 500:
                errorMessage = "Сервер временно недоступен. Попробуйте позже."
            default:
                errorMessage = api.errorDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
