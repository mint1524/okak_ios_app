
import SwiftUI

struct RootView: View {
    @StateObject private var deps = AppDependencies()
    @StateObject private var network = NetworkMonitor()

    var body: some View {
        Group {
            switch deps.session.state {
            case .unknown:
                splash
            case .unauthenticated:
                LoginView(vm: LoginViewModel(auth: deps.authService))
                    .transition(.opacity)
            case .pendingEmailVerification(let email):
                NavigationStack {
                    EmailVerificationView(
                        vm: EmailVerificationViewModel(email: email, auth: deps.authService)
                    )
                }
                .transition(.opacity)
            case .authenticated:
                AuthenticatedPlaceholderView()
                    .environmentObject(deps)
                    .transition(.opacity)
            }
        }
        .environmentObject(deps.session)
        .environmentObject(network)
        .animation(.default, value: deps.session.state)
        .task { await deps.session.restore() }
    }

    private var splash: some View {
        VStack(spacing: OKSpacing.m) {
            Text("OKAK").font(OKFont.brand).foregroundStyle(OKColor.accent)
            ProgressView().tint(OKColor.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OKColor.background.ignoresSafeArea())
    }
}

struct AuthenticatedPlaceholderView: View {
    @EnvironmentObject var deps: AppDependencies

    var body: some View {
        VStack(spacing: OKSpacing.m) {
            Text("Главный экран")
                .font(OKFont.title)
            Text("Скоро здесь появится AI Chat, магазин и аккаунт.")
                .font(OKFont.footnote)
                .foregroundStyle(OKColor.textSecondary)
            Button("Выйти") {
                Task { await deps.authService.logout() }
            }
            .buttonStyle(OKSecondaryButtonStyle())
            .padding(.top, OKSpacing.l)
        }
        .padding(OKSpacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OKColor.background.ignoresSafeArea())
    }
}
