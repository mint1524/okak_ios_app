
import Foundation

protocol SessionsServiceType: AnyObject, Sendable {
    func list() async throws -> [SessionDTO]
    func revoke(id: String) async throws
    func revokeCurrent() async throws
}

final class SessionsService: SessionsServiceType, @unchecked Sendable {
    private let api: APIClientType
    init(api: APIClientType) { self.api = api }

    func list() async throws -> [SessionDTO] {
        let endpoint = APIEndpoint(method: .get, path: "sessions")
        return try await api.send(endpoint, as: SessionsListResponse.self).items
    }

    func revoke(id: String) async throws {
        let endpoint = APIEndpoint(method: .delete, path: "sessions/\(id)")
        try await api.sendVoid(endpoint)
    }

    func revokeCurrent() async throws {
        let endpoint = APIEndpoint(method: .delete, path: "sessions/current")
        try await api.sendVoid(endpoint)
    }
}
