
import Foundation

protocol ProfileServiceType: AnyObject, Sendable {
    func get() async throws -> ProfileDTO
    func update(_ request: UpdateProfileRequest) async throws -> ProfileDTO
    func resetAIPersonalization() async throws -> ProfileDTO
}

final class ProfileService: ProfileServiceType, @unchecked Sendable {
    private let api: APIClientType
    init(api: APIClientType) { self.api = api }

    func get() async throws -> ProfileDTO {
        let endpoint = APIEndpoint(method: .get, path: "profile")
        return try await api.send(endpoint, as: ProfileDTO.self)
    }

    func update(_ request: UpdateProfileRequest) async throws -> ProfileDTO {
        var endpoint = APIEndpoint(method: .patch, path: "profile")
        endpoint.body = try APIEndpoint.jsonBody(request)
        return try await api.send(endpoint, as: ProfileDTO.self)
    }

    func resetAIPersonalization() async throws -> ProfileDTO {
        let endpoint = APIEndpoint(method: .post, path: "profile/ai-personalization/reset")
        return try await api.send(endpoint, as: ProfileDTO.self)
    }
}
