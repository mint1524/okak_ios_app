
import SwiftUI

@MainActor
final class ToastPresenter: ObservableObject {
    struct Toast: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let kind: Kind
        enum Kind { case info, success, warning, error }
    }

    @Published var current: Toast?
    private var task: Task<Void, Never>?

    func show(_ title: String, kind: Toast.Kind = .info) {
        current = Toast(title: title, kind: kind)
        task?.cancel()
        task = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run { self?.current = nil }
        }
    }
}

struct ToastOverlay: ViewModifier {
    @ObservedObject var presenter: ToastPresenter

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if let toast = presenter.current {
                HStack(spacing: OKSpacing.s) {
                    Image(systemName: iconName(for: toast.kind))
                        .foregroundStyle(.white)
                    Text(toast.title)
                        .font(OKFont.footnote)
                        .foregroundStyle(.white)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, OKSpacing.l)
                .padding(.vertical, OKSpacing.m)
                .background(
                    RoundedRectangle(cornerRadius: OKRadius.l)
                        .fill(color(for: toast.kind))
                )
                .padding(.horizontal, OKSpacing.l)
                .padding(.top, OKSpacing.s)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4), value: presenter.current)
    }

    private func iconName(for kind: ToastPresenter.Toast.Kind) -> String {
        switch kind {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }

    private func color(for kind: ToastPresenter.Toast.Kind) -> Color {
        switch kind {
        case .info: return OKColor.accent
        case .success: return OKColor.success
        case .warning: return OKColor.warning
        case .error: return OKColor.danger
        }
    }
}

extension View {
    func toast(_ presenter: ToastPresenter) -> some View {
        modifier(ToastOverlay(presenter: presenter))
    }
}
