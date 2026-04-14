
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: ProfileDTO?
    @Published var displayName: String = ""
    @Published var language: String = "ru"
    @Published var theme: String = "system"
    @Published var aiPersonalization: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var savedFlash: Bool = false

    private let service: ProfileServiceType
    init(service: ProfileServiceType) { self.service = service }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let p = try await service.get()
            apply(p)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        do {
            let req = UpdateProfileRequest(
                displayName: displayName.isEmpty ? nil : displayName,
                language: language,
                theme: theme,
                communicationStyle: nil,
                interests: nil,
                aiPersonalizationEnabled: aiPersonalization
            )
            let p = try await service.update(req)
            apply(p)
            savedFlash = true
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetAIPersonalization() async {
        do {
            let p = try await service.resetAIPersonalization()
            apply(p)
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func apply(_ p: ProfileDTO) {
        profile = p
        displayName = p.displayName ?? ""
        language = p.language
        theme = p.theme
        aiPersonalization = p.aiPersonalizationEnabled
    }
}
