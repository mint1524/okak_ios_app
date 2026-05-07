// OKAK_APPTests.swift
// XCTest unit tests for the OKAK iOS application
// Covers: API error handling, auth model encoding/decoding, chat models,
//         commerce models, configuration, password validation, quota logic.

import XCTest
@testable import OKAK_APP

// MARK: - Helpers

private let decoder: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .iso8601
    return d
}()

private func json(_ dict: [String: Any]) -> Data {
    try! JSONSerialization.data(withJSONObject: dict)
}

// =============================================================================
// MARK: - 1. APIError
// =============================================================================

final class APIErrorTests: XCTestCase {
    func test_invalidURL_errorDescription() {
        let error = APIError.invalidURL
        XCTAssertNotNil(error.errorDescription)
    }
    func test_transport_errorDescription() {
        let error = APIError.transport("Connection timed out")
        XCTAssertTrue(error.errorDescription?.contains("timed out") == true)
    }
    func test_unauthorized_errorDescription() {
        let error = APIError.unauthorized
        XCTAssertNotNil(error.errorDescription)
    }
    func test_quotaExceeded_errorDescription() {
        let error = APIError.quotaExceeded
        XCTAssertNotNil(error.errorDescription)
    }
    func test_decoding_errorDescription() {
        let error = APIError.decoding("Expected String, got Int")
        XCTAssertTrue(error.errorDescription?.contains("Expected String") == true)
    }
    func test_server_errorDescription() {
        let error = APIError.server(401, "Unauthorized")
        XCTAssertTrue(error.errorDescription?.contains("401") == true)
    }
    func test_equatable_sameErrors() {
        XCTAssertEqual(APIError.invalidURL, APIError.invalidURL)
        XCTAssertEqual(APIError.unauthorized, APIError.unauthorized)
        XCTAssertEqual(APIError.transport("msg"), APIError.transport("msg"))
        XCTAssertEqual(APIError.server(404, "Not found"), APIError.server(404, "Not found"))
    }
    func test_equatable_differentErrors() {
        XCTAssertNotEqual(APIError.invalidURL, APIError.unauthorized)
        XCTAssertNotEqual(APIError.transport("a"), APIError.transport("b"))
        XCTAssertNotEqual(APIError.server(400, "x"), APIError.server(500, "y"))
    }
}

// =============================================================================
// MARK: - 2. Auth Models — encoding & decoding
// =============================================================================

final class AuthModelTests: XCTestCase {
    func test_registerRequest_encoding() throws {
        let request = RegisterRequest(
            email: "user@okak.club",
            password: "securepass1",
            dateOfBirth: "2000-01-01",
            acceptedTerms: true
        )
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["email"] as? String, "user@okak.club")
        XCTAssertEqual(dict["password"] as? String, "securepass1")
        XCTAssertEqual(dict["accepted_terms"] as? Bool, true)
    }
    func test_loginRequest_encoding() throws {
        let request = LoginRequest(identifier: "user@okak.club", password: "mypassword")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["identifier"] as? String, "user@okak.club")
        XCTAssertEqual(dict["password"] as? String, "mypassword")
    }
    func test_loginRequest_withUsername() throws {
        let request = LoginRequest(identifier: "okakuser", password: "pass")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["identifier"] as? String, "okakuser")
    }
    func test_verifyEmailRequest_encoding() throws {
        let request = VerifyEmailRequest(email: "test@okak.club", code: "123456")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["email"] as? String, "test@okak.club")
        XCTAssertEqual(dict["code"] as? String, "123456")
    }
    func test_passwordResetRequest_encoding() throws {
        let request = PasswordResetRequest(email: "user@okak.club")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["email"] as? String, "user@okak.club")
    }
    func test_registerResponse_decoding() throws {
        let data = json(["user_id": "abc-123", "email": "user@okak.club"])
        let response = try decoder.decode(RegisterResponse.self, from: data)
        XCTAssertEqual(response.userId, "abc-123")
        XCTAssertEqual(response.email, "user@okak.club")
        XCTAssertNil(response.verificationCodeDev)
    }
    func test_authUserDTO_decoding() throws {
        let data = json([
            "id": "u1",
            "email": "a@b.com",
            "email_verified": true,
            "role": "user"
        ])
        let user = try decoder.decode(AuthUserDTO.self, from: data)
        XCTAssertEqual(user.id, "u1")
        XCTAssertEqual(user.email, "a@b.com")
        XCTAssertEqual(user.role, "user")
        XCTAssertTrue(user.emailVerified)
    }
    func test_authUserDTO_optionalFields_nil() throws {
        let data = json(["id": "u2", "email": "b@c.com", "email_verified": false])
        let user = try decoder.decode(AuthUserDTO.self, from: data)
        XCTAssertNil(user.username)
        XCTAssertNil(user.name)
        XCTAssertNil(user.role)
    }
}

// =============================================================================
// MARK: - 3. Chat & Quota Models
// =============================================================================

final class ChatModelTests: XCTestCase {
    func test_quotaDTO_decoding_freePlan() throws {
        let data = json([
            "plan_name": "free",
            "limit": 4,
            "used": 2
        ])
        let quota = try decoder.decode(QuotaDTO.self, from: data)
        XCTAssertEqual(quota.planName, "free")
        XCTAssertEqual(quota.limit, 4)
        XCTAssertEqual(quota.used, 2)
        XCTAssertEqual(quota.remaining, 2)
    }
    func test_quotaDTO_exhausted() throws {
        let data = json(["plan_name": "free", "limit": 4, "used": 4])
        let quota = try decoder.decode(QuotaDTO.self, from: data)
        XCTAssertEqual(quota.remaining, 0)
    }
    func test_chatDTO_decoding() throws {
        let data = json([
            "id": "thread-1",
            "title": "Test chat",
            "model": "okak-mini",
            "reasoning_level": "balanced",
            "search_enabled": false,
            "streaming_enabled": true,
            "created_at": "2025-01-01T00:00:00Z",
            "updated_at": "2025-01-01T00:00:00Z"
        ])
        let thread = try decoder.decode(ChatDTO.self, from: data)
        XCTAssertEqual(thread.id, "thread-1")
        XCTAssertEqual(thread.title, "Test chat")
        XCTAssertEqual(thread.model, "okak-mini")
        XCTAssertTrue(thread.streamingEnabled)
        XCTAssertFalse(thread.searchEnabled)
    }
    func test_createChatRequest_encoding() throws {
        let request = CreateChatRequest(
            title: "My chat",
            model: "okak-mini",
            reasoningLevel: "balanced",
            searchEnabled: false,
            streamingEnabled: true
        )
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["title"] as? String, "My chat")
        XCTAssertEqual(dict["model"] as? String, "okak-mini")
        XCTAssertEqual(dict["streaming_enabled"] as? Bool, true)
    }
    func test_messageDTO_decoding() throws {
        let data = json([
            "id": "msg-1",
            "chat_id": "thread-1",
            "role": "assistant",
            "content": "Hello, how can I help?",
            "status": "completed",
            "attachments": [],
            "created_at": "2025-01-01T00:00:00Z"
        ])
        let msg = try decoder.decode(MessageDTO.self, from: data)
        XCTAssertEqual(msg.role, .assistant)
        XCTAssertEqual(msg.content, "Hello, how can I help?")
        XCTAssertEqual(msg.status, .completed)
    }
    func test_sendMessageRequest_encoding() throws {
        let request = SendMessageRequest(content: "What is Swift?", attachments: nil)
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["content"] as? String, "What is Swift?")
    }
}

// =============================================================================
// MARK: - 4. Commerce Models
// =============================================================================

final class CommerceModelTests: XCTestCase {
    func test_subscriptionDTO_decoding() throws {
        let data = json([
            "id": "sub-1",
            "name": "AI Monthly",
            "description": "Access to AI chat",
            "price": 999.00,
            "currency": "RUB",
            "duration_days": 30,
            "type": "llm",
            "status": "active",
            "quota_limit": 100,
            "features": ["ai_chat", "history"]
        ])
        let sub = try decoder.decode(SubscriptionDTO.self, from: data)
        XCTAssertEqual(sub.id, "sub-1")
        XCTAssertEqual(sub.name, "AI Monthly")
        XCTAssertEqual(sub.currency, "RUB")
        XCTAssertEqual(sub.durationDays, 30)
        XCTAssertEqual(sub.quotaLimit, 100)
        XCTAssertTrue(sub.features.contains("ai_chat"))
    }
    func test_orderDTO_decoding() throws {
        let data = json([
            "id": "order-1",
            "subscription_id": "sub-1",
            "subscription_name": "AI Monthly",
            "amount": 999.00,
            "currency": "RUB",
            "status": "completed",
            "created_at": "2025-01-01T00:00:00Z"
        ])
        let order = try decoder.decode(OrderDTO.self, from: data)
        XCTAssertEqual(order.id, "order-1")
        XCTAssertEqual(order.status, "completed")
        XCTAssertNil(order.paymentId)
    }
    func test_createOrderRequest_encoding() throws {
        let request = CreateOrderRequest(subscriptionId: "sub-1")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["subscription_id"] as? String, "sub-1")
    }
    func test_userSubscriptionDTO_decoding() throws {
        let data = json([
            "id": "usub-1",
            "subscription_id": "sub-1",
            "name": "AI Monthly",
            "status": "active",
            "start_date": "2025-01-01T00:00:00Z",
            "end_date": "2025-02-01T00:00:00Z",
            "auto_renew": true,
            "quota_limit": 100
        ])
        let userSub = try decoder.decode(UserSubscriptionDTO.self, from: data)
        XCTAssertEqual(userSub.id, "usub-1")
        XCTAssertEqual(userSub.status, "active")
        XCTAssertTrue(userSub.autoRenew)
        XCTAssertEqual(userSub.quotaLimit, 100)
    }
}

// =============================================================================
// MARK: - 5. AppConfiguration
// =============================================================================

final class AppConfigurationTests: XCTestCase {
    func test_defaultConfig_apiBaseURL_notNil() {
        XCTAssertNotNil(AppConfiguration.default.apiBaseURL)
    }
    func test_customConfig_apiBaseURL() {
        let config = AppConfiguration(
            apiBaseURL: URL(string: "https://api.okak.club")!,
            environmentName: "production"
        )
        XCTAssertEqual(config.apiBaseURL.host, "api.okak.club")
    }
    func test_customConfig_environmentName() {
        let config = AppConfiguration(
            apiBaseURL: URL(string: "https://api.okak.club")!,
            environmentName: "staging"
        )
        XCTAssertEqual(config.environmentName, "staging")
    }
}

// =============================================================================
// MARK: - 6. Password Validation Logic
// =============================================================================

// Replicates the password length rule from RegisterFormView:
// password must be at least 10 characters.
final class PasswordValidationTests: XCTestCase {
    private func isPasswordValid(_ password: String) -> Bool {
        password.count >= 10
    }
    func test_password_exactlyTenChars_isValid() {
        XCTAssertTrue(isPasswordValid("1234567890"))
    }
    func test_password_moreThanTen_isValid() {
        XCTAssertTrue(isPasswordValid("securePassword123!"))
    }
    func test_password_nineChars_isInvalid() {
        XCTAssertFalse(isPasswordValid("123456789"))
    }
    func test_password_empty_isInvalid() {
        XCTAssertFalse(isPasswordValid(""))
    }
    func test_password_oneChar_isInvalid() {
        XCTAssertFalse(isPasswordValid("a"))
    }
    func test_password_withSpaces_countsByCharacter() {
        // "1234 6789 " = 10 chars including spaces — valid
        XCTAssertTrue(isPasswordValid("1234 6789 "))
    }
}

// =============================================================================
// MARK: - 7. Quota Exhaustion Logic
// =============================================================================

// Replicates the canSend logic used in ChatDetailViewModel.
final class QuotaExhaustionTests: XCTestCase {
    private func canSendMessage(quota: QuotaDTO) -> Bool {
        quota.remaining > 0
    }
    func test_freePlan_hasRemaining_canSend() throws {
        let quota = try decoder.decode(QuotaDTO.self, from: json([
            "plan_name": "free", "limit": 4, "used": 2
        ]))
        XCTAssertTrue(canSendMessage(quota: quota))
    }
    func test_freePlan_exhausted_cannotSend() throws {
        let quota = try decoder.decode(QuotaDTO.self, from: json([
            "plan_name": "free", "limit": 4, "used": 4
        ]))
        XCTAssertFalse(canSendMessage(quota: quota))
    }
    func test_freePlan_oneRemaining_canSend() throws {
        let quota = try decoder.decode(QuotaDTO.self, from: json([
            "plan_name": "free", "limit": 4, "used": 3
        ]))
        XCTAssertTrue(canSendMessage(quota: quota))
    }
    func test_quotaDTO_equatable() throws {
        let a = try decoder.decode(QuotaDTO.self, from: json([
            "plan_name": "free", "limit": 4, "used": 2
        ]))
        let b = try decoder.decode(QuotaDTO.self, from: json([
            "plan_name": "free", "limit": 4, "used": 2
        ]))
        XCTAssertEqual(a, b)
    }
}
