
import Foundation

struct APIEndpoint {
    let method: HTTPMethod
    let path: String
    var query: [URLQueryItem] = []
    var body: Data?
    var headers: [String: String] = [:]
    var requiresAuth: Bool = true
}

extension APIEndpoint {
    static func jsonBody<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }
}
