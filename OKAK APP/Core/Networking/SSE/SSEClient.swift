
import Foundation

protocol SSEClientType: Sendable {
    func events(for endpoint: APIEndpoint) -> AsyncThrowingStream<SSEEvent, Error>
}

final class SSEClient: SSEClientType, @unchecked Sendable {
    private let api: APIClientType
    private let session: URLSession

    init(api: APIClientType, session: URLSession = .shared) {
        self.api = api
        self.session = session
    }

    func events(for endpoint: APIEndpoint) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = try await api.makeURLRequest(endpoint)
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    let (bytes, response) = try await session.bytes(for: request)
                    if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                        switch http.statusCode {
                        case 401: throw APIError.unauthorized
                        case 429: throw APIError.quotaExceeded
                        case 503: throw APIError.llmUnavailable
                        default: throw APIError.server(http.statusCode, "Stream error")
                        }
                    }
                    var event = SSEEvent(event: nil, data: "", id: nil)
                    for try await line in bytes.lines {
                        if line.isEmpty {
                            if !event.data.isEmpty {
                                continuation.yield(event)
                            }
                            event = SSEEvent(event: nil, data: "", id: nil)
                            continue
                        }
                        if line.hasPrefix(":") { continue }
                        if let colon = line.firstIndex(of: ":") {
                            let field = String(line[..<colon])
                            var value = String(line[line.index(after: colon)...])
                            if value.hasPrefix(" ") { value.removeFirst() }
                            switch field {
                            case "event": event.event = value
                            case "data":
                                if event.data.isEmpty {
                                    event.data = value
                                } else {
                                    event.data += "\n" + value
                                }
                            case "id": event.id = value
                            default: break
                            }
                        }
                    }
                    if !event.data.isEmpty { continuation.yield(event) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
