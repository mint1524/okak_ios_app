
import Foundation

struct AuthTokens: Decodable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct AuthUserDTO: Decodable, Equatable, Identifiable, Sendable {
    let id: String
    let email: String
    let username: String?
    let name: String?
    let emailVerified: Bool
    let subscriptionStatus: String?
    let role: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case name
        case emailVerified = "email_verified"
        case subscriptionStatus = "subscription_status"
        case role
    }
}

struct AuthResponse: Decodable, Sendable {
    let user: AuthUserDTO
    let tokens: AuthTokens
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let dateOfBirth: String
    let acceptedTerms: Bool

    enum CodingKeys: String, CodingKey {
        case email
        case password
        case dateOfBirth = "date_of_birth"
        case acceptedTerms = "accepted_terms"
    }
}

struct VerifyEmailRequest: Encodable {
    let email: String
    let code: String
}

struct LoginRequest: Encodable {
    let identifier: String
    let password: String
}

struct PasswordResetRequest: Encodable {
    let email: String
}

struct PasswordResetConfirm: Encodable {
    let email: String
    let code: String
    let password: String
}

struct RegisterResponse: Decodable, Sendable {
    let userId: String
    let email: String
    let verificationCodeDev: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case verificationCodeDev = "verification_code_dev"
    }
}

struct OKMessage: Decodable, Sendable {
    let message: String
}
