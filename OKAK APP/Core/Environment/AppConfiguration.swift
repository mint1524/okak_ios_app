
import Foundation

struct AppConfiguration: Sendable {
    let apiBaseURL: URL
    let environmentName: String

    nonisolated(unsafe) static let `default`: AppConfiguration = {
        #if targetEnvironment(simulator)
        let host = "http://127.0.0.1:3000"
        #else
        let host = Bundle.main.object(forInfoDictionaryKey: "OKAK_API_BASE_URL") as? String ?? "https://api.okak.local"
        #endif
        return AppConfiguration(
            apiBaseURL: URL(string: host)!,
            environmentName: "development"
        )
    }()
}
