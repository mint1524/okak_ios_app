
import Foundation
import os

enum OKLog {
    static let app = Logger(subsystem: "club.okak.app", category: "app")
    static let net = Logger(subsystem: "club.okak.app", category: "net")
    static let auth = Logger(subsystem: "club.okak.app", category: "auth")
    static let chat = Logger(subsystem: "club.okak.app", category: "chat")
}
