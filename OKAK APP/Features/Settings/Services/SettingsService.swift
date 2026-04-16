
import Foundation

protocol SettingsServiceType: AnyObject, Sendable {
    func get() async throws -> AppSettingsDTO
    func update(_ request: UpdateSettingsRequest) async throws -> AppSettingsDTO
}

final class SettingsService: SettingsServiceType, @unchecked Sendable {
    private let api: APIClientType
    init(api: APIClientType) { self.api = api }

    func get() async throws -> AppSettingsDTO {
        let endpoint = APIEndpoint(method: .get, path: "settings")
        return try await api.send(endpoint, as: AppSettingsDTO.self)
    }

    func update(_ request: UpdateSettingsRequest) async throws -> AppSettingsDTO {
        var endpoint = APIEndpoint(method: .patch, path: "settings")
        endpoint.body = try APIEndpoint.jsonBody(request)
        return try await api.send(endpoint, as: AppSettingsDTO.self)
    }
}
