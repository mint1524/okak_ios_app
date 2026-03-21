
import Foundation

@MainActor
final class PasswordResetViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var didSend: Bool = false

    let auth: AuthServiceType

    init(auth: AuthServiceType) {
        self.auth = auth
    }

    var canSubmit: Bool {
        AuthValidation.isValidEmail(email) && !isLoading
    }

    func submit() async {
        errorMessage = nil
        didSend = false
        guard canSubmit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.requestPasswordReset(email: email.lowercased())
            didSend = true
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
