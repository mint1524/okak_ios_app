
import SwiftUI
import Combine

struct RecommendationsView: View {
    @StateObject var vm: RecommendationsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: OKSpacing.m) {
            HStack {
                Label("Подобрано для вас", systemImage: "sparkles")
                    .font(OKFont.bodyBold)
                    .foregroundStyle(OKColor.accent)
                Spacer()
                Button("Обновить") { Task { await vm.refresh() } }
                    .font(OKFont.caption)
            }
            if vm.items.isEmpty {
                Text("Используйте AI Chat, чтобы получить персональные рекомендации.")
                    .font(OKFont.footnote)
                    .foregroundStyle(OKColor.textSecondary)
            } else {
                ForEach(vm.items) { rec in
                    VStack(alignment: .leading, spacing: OKSpacing.xs) {
                        Text(rec.title).font(OKFont.bodyBold)
                        Text(rec.reason).font(OKFont.footnote).foregroundStyle(OKColor.textSecondary)
                        HStack {
                            ProgressView(value: rec.confidence)
                                .progressViewStyle(.linear)
                                .tint(OKColor.accent)
                            Text("\(Int(rec.confidence * 100))%")
                                .font(OKFont.caption)
                                .foregroundStyle(OKColor.textSecondary)
                        }
                    }
                    .padding(OKSpacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: OKRadius.m)
                            .fill(OKColor.surface)
                    )
                }
            }
        }
        .task { await vm.refresh() }
    }
}

@MainActor
final class RecommendationsViewModel: ObservableObject {
    @Published private(set) var items: [RecommendationDTO] = []
    @Published var errorMessage: String?

    private let service: RecommendationsServiceType
    init(service: RecommendationsServiceType) {
        self.service = service
    }

    func refresh() async {
        do {
            items = try await service.list()
        } catch let api as APIError {
            errorMessage = api.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
