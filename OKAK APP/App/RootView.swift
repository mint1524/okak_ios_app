
import SwiftUI

struct RootView: View {
    @StateObject private var deps = AppDependencies()
    @StateObject private var network = NetworkMonitor()
    @StateObject private var toasts = ToastPresenter()

    var body: some View {
        VStack(spacing: 0) {
            if !network.isOnline {
                OfflineBanner()
            }
            content
        }
        .environmentObject(deps.session)
        .environmentObject(network)
        .environmentObject(toasts)
        .toast(toasts)
        .animation(.default, value: deps.session.state)
        .animation(.default, value: network.isOnline)
        .task { await deps.session.restore() }
    }

    @ViewBuilder
    private var content: some View {
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
                HomeTabView()
                    .environmentObject(deps)
                    .transition(.opacity)
            }
        }
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


