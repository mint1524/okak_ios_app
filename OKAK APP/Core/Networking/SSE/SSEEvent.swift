
import Foundation

struct SSEEvent: Sendable, Equatable {
    var event: String?
    var data: String
    var id: String?
}
