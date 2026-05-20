
import Foundation

@preconcurrency protocol APIClientType: AnyObject, Sendable {
    func send<T: Decodable>(_ endpoint: APIEndpoint, as type: T.Type) async throws -> T
    func sendVoid(_ endpoint: APIEndpoint) async throws
    func rawData(_ endpoint: APIEndpoint) async throws -> Data
    func makeURLRequest(_ endpoint: APIEndpoint) async throws -> URLRequest
}

final class APIClient: APIClientType, @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: () async -> String?
    private let onUnauthorized: () async -> Void
    private let decoder: JSONDecoder

    init(baseURL: URL,
         session: URLSession = .shared,
         tokenProvider: @escaping () async -> String?,
         onUnauthorized: @escaping () async -> Void = {}) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
        self.onUnauthorized = onUnauthorized
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func makeURLRequest(_ endpoint: APIEndpoint) async throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                             resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !endpoint.query.isEmpty {
            components.queryItems = endpoint.query
        }
        guard let url = components.url else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        for (k, v) in endpoint.headers {
            request.setValue(v, forHTTPHeaderField: k)
        }
        if endpoint.requiresAuth, let token = await tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    func rawData(_ endpoint: APIEndpoint) async throws -> Data {
        let request = try await makeURLRequest(endpoint)
        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data)
            return data
        } catch let error as APIError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw APIError.noNetwork
            case .cancelled:
                throw APIError.cancelled
            default:
                throw APIError.transport(urlError.localizedDescription)
            }
        } catch {
            throw APIError.transport(error.localizedDescription)
        }
    }

    func send<T: Decodable>(_ endpoint: APIEndpoint, as type: T.Type) async throws -> T {
        let data = try await rawData(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }

    func sendVoid(_ endpoint: APIEndpoint) async throws {
        _ = try await rawData(endpoint)
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.transport("Ответ без HTTP-статуса")
        }
        switch http.statusCode {
        case 200..<300:
            return
        case 401:
            Task { await onUnauthorized() }
            throw APIError.unauthorized
        case 403:
            let body = try? decoder.decode(APIErrorBody.self, from: data)
            throw APIError.forbidden(body?.message)
        case 404:
            throw APIError.notFound
        case 409:
            let body = (try? decoder.decode(APIErrorBody.self, from: data))?.message ?? "Конфликт данных"
            throw APIError.validation(body)
        case 422:
            let body = (try? decoder.decode(APIErrorBody.self, from: data))?.message ?? "Некорректные данные"
            throw APIError.validation(body)
        case 429:
            let body = try? decoder.decode(APIErrorBody.self, from: data)
            if body?.code == "QUOTA_EXCEEDED" {
                throw APIError.quotaExceeded
            }
            throw APIError.validation(body?.message ?? "Слишком много запросов")
        case 503:
            let body = try? decoder.decode(APIErrorBody.self, from: data)
            if body?.code == "LLM_UNAVAILABLE" {
                throw APIError.llmUnavailable
            }
            throw APIError.server(http.statusCode, body?.message ?? "Сервис недоступен")
        default:
            let body = (try? decoder.decode(APIErrorBody.self, from: data))?.message ?? "Ошибка"
            throw APIError.server(http.statusCode, body)
        }
    }
}
