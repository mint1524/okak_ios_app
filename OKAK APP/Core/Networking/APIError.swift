
import Foundation

struct APIErrorBody: Decodable {
    let error: String?
    let message: String?
    let code: String?
}

enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case transport(String)
    case decoding(String)
    case unauthorized
    case forbidden
    case notFound
    case quotaExceeded
    case validation(String)
    case server(Int, String)
    case noNetwork
    case cancelled
    case llmUnavailable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Некорректный URL запроса."
        case .transport(let m): return "Ошибка сети: \(m)"
        case .decoding(let m): return "Ошибка обработки ответа: \(m)"
        case .unauthorized: return "Сессия истекла. Войдите снова."
        case .forbidden: return "Доступ запрещён."
        case .notFound: return "Объект не найден."
        case .quotaExceeded: return "Квота AI-запросов исчерпана."
        case .validation(let m): return m
        case .server(let code, let m): return "Ошибка сервера (\(code)): \(m)"
        case .noNetwork: return "Нет соединения с сетью."
        case .cancelled: return "Запрос отменён."
        case .llmUnavailable: return "AI-сервис временно недоступен."
        case .unknown(let m): return m
        }
    }
}
