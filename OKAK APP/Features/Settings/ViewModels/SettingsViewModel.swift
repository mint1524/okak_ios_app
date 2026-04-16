
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var language: String = "ru"
    @Published var theme: String = "system"
    @Published var notifications: Bool = true
    @Published var analytics: Bool = false
    @Published var errorMessage: String?

    private let service: SettingsServiceType
    init(service: SettingsServiceType) { self.service = service }

    func load() async {
        do {
            let s = try await service.get()
            language = s.language
            theme = s.theme
            notifications = s.notificationsEnabled
            analytics = s.analyticsEnabled
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        do {
            _ = try await service.update(UpdateSettingsRequest(
                language: language,
                theme: theme,
                notificationsEnabled: notifications,
                analyticsEnabled: analytics
            ))
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
