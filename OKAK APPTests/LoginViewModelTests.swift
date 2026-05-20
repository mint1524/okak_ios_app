
import Testing
import Foundation
@testable import OKAK_APP

@MainActor
struct LoginViewModelTests {
    @Test func disablesSubmitWhenEmpty() {
        let vm = LoginViewModel(auth: MockAuthService())
        #expect(!vm.canSubmit)
        vm.identifier = "user@okak.club"
        #expect(!vm.canSubmit)
        vm.password = "testpass" // TODO: замените на реальный тестовый пароль
        #expect(vm.canSubmit)
    }

    @Test func wrongCredentialsShowError() async {
        let mock = MockAuthService()
        mock.loginError = .unauthorized
        let vm = LoginViewModel(auth: mock)
        vm.identifier = "user@okak.club"
        vm.password = "testpass" // TODO: замените на реальный тестовый пароль
        await vm.submit()
        #expect(vm.errorMessage == "Неверный логин или пароль")
    }
}

final class MockAuthService: AuthServiceType, @unchecked Sendable {
    var loginError: APIError?

    func register(email: String, password: String, dateOfBirth: Date) async throws -> RegisterResponse {
        RegisterResponse(userId: "u1", email: email, verificationCodeDev: "123456")
    }
    func verifyEmail(email: String, code: String) async throws -> AuthUserDTO {
        AuthUserDTO(id: "u1", email: email, username: nil, name: nil, emailVerified: true, subscriptionStatus: nil, role: nil)
    }
    func login(identifier: String, password: String) async throws -> AuthUserDTO {
        if let err = loginError { throw err }
        return AuthUserDTO(id: "u1", email: identifier, username: nil, name: nil, emailVerified: true, subscriptionStatus: nil, role: nil)
    }
    func requestPasswordReset(email: String) async throws {}
    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {}
    func markPendingVerification(email: String) async {}
    func me() async throws -> AuthUserDTO {
        AuthUserDTO(id: "u1", email: "demo@okak.app", username: nil, name: nil, emailVerified: true, subscriptionStatus: nil, role: nil)
    }
    func logout() async {}
    func resendVerification(email: String) async throws {}
}
