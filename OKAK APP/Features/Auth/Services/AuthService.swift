
import Foundation

protocol AuthServiceType: AnyObject, Sendable {
    func register(email: String, password: String, dateOfBirth: Date) async throws -> RegisterResponse
    func verifyEmail(email: String, code: String) async throws -> AuthUserDTO
    func login(identifier: String, password: String) async throws -> AuthUserDTO
    func requestPasswordReset(email: String) async throws
    func confirmPasswordReset(token: String, newPassword: String) async throws
    func me() async throws -> AuthUserDTO
    func logout() async
    func resendVerification(email: String) async throws
}

final class AuthService: AuthServiceType, @unchecked Sendable {
    private let api: APIClientType
    private let session: SessionStore

    init(api: APIClientType, session: SessionStore) {
        self.api = api
        self.session = session
    }

    func register(email: String, password: String, dateOfBirth: Date) async throws -> RegisterResponse {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let body = RegisterRequest(
            email: email,
            password: password,
            dateOfBirth: formatter.string(from: dateOfBirth),
            acceptedTerms: true
        )
        var endpoint = APIEndpoint(method: .post, path: "auth/register")
        endpoint.body = try APIEndpoint.jsonBody(body)
        endpoint.requiresAuth = false
        let result = try await api.send(endpoint, as: RegisterResponse.self)
        await MainActor.run { try? session.markPendingVerification(email: result.email) }
        return result
    }

    func verifyEmail(email: String, code: String) async throws -> AuthUserDTO {
        var endpoint = APIEndpoint(method: .post, path: "auth/verify-email")
        endpoint.body = try APIEndpoint.jsonBody(VerifyEmailRequest(email: email, code: code))
        endpoint.requiresAuth = false
        let response = try await api.send(endpoint, as: AuthResponse.self)
        try await MainActor.run {
            try session.setTokens(
                access: response.tokens.accessToken,
                refresh: response.tokens.refreshToken,
                userID: response.user.id
            )
        }
        return response.user
    }

    func login(identifier: String, password: String) async throws -> AuthUserDTO {
        var endpoint = APIEndpoint(method: .post, path: "auth/login")
        endpoint.body = try APIEndpoint.jsonBody(LoginRequest(identifier: identifier, password: password))
        endpoint.requiresAuth = false
        let response = try await api.send(endpoint, as: AuthResponse.self)
        try await MainActor.run {
            try session.setTokens(
                access: response.tokens.accessToken,
                refresh: response.tokens.refreshToken,
                userID: response.user.id
            )
        }
        return response.user
    }

    func requestPasswordReset(email: String) async throws {
        var endpoint = APIEndpoint(method: .post, path: "auth/password-reset/request")
        endpoint.body = try APIEndpoint.jsonBody(PasswordResetRequest(email: email))
        endpoint.requiresAuth = false
        try await api.sendVoid(endpoint)
    }

    func confirmPasswordReset(token: String, newPassword: String) async throws {
        var endpoint = APIEndpoint(method: .post, path: "auth/password-reset/confirm")
        endpoint.body = try APIEndpoint.jsonBody(PasswordResetConfirm(token: token, password: newPassword))
        endpoint.requiresAuth = false
        try await api.sendVoid(endpoint)
    }

    func me() async throws -> AuthUserDTO {
        let endpoint = APIEndpoint(method: .get, path: "auth/me")
        return try await api.send(endpoint, as: AuthUserDTO.self)
    }

    func resendVerification(email: String) async throws {
        var endpoint = APIEndpoint(method: .post, path: "auth/verify-email/resend")
        endpoint.body = try APIEndpoint.jsonBody(PasswordResetRequest(email: email))
        endpoint.requiresAuth = false
        try await api.sendVoid(endpoint)
    }

    func logout() async {
        let endpoint = APIEndpoint(method: .post, path: "auth/logout")
        try? await api.sendVoid(endpoint)
        await MainActor.run { session.signOut() }
    }
}
