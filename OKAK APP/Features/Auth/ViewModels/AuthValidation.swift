
import Foundation

enum AuthValidation {
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func passwordIssue(_ password: String) -> String? {
        if password.count < 10 { return "Пароль должен быть не короче 10 символов" }
        if password.range(of: "[A-Za-z]", options: .regularExpression) == nil {
            return "Пароль должен содержать буквы"
        }
        if password.range(of: "[0-9]", options: .regularExpression) == nil {
            return "Пароль должен содержать цифры"
        }
        return nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        passwordIssue(password) == nil
    }

    static func isAdult(_ dateOfBirth: Date) -> Bool {
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        return age >= 14
    }
}
