
import SwiftUI

struct SessionsView: View {
    @StateObject var vm: SessionsViewModel
    @State private var revokeTarget: SessionDTO?

    var body: some View {
        List {
            ForEach(vm.sessions) { s in
                SessionRow(session: s)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if !s.isCurrent {
                            Button("Завершить", role: .destructive) {
                                revokeTarget = s
                            }
                        }
                    }
            }
            if vm.sessions.isEmpty {
                Text("Нет активных сессий")
                    .foregroundStyle(OKColor.textSecondary)
            }
            if let err = vm.errorMessage {
                Text(err).foregroundStyle(OKColor.danger)
            }
        }
        .navigationTitle("Сессии")
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
        .confirmationDialog(
            "Завершить сессию?",
            isPresented: Binding(
                get: { revokeTarget != nil },
                set: { if !$0 { revokeTarget = nil } }
            ),
            presenting: revokeTarget
        ) { s in
            Button("Завершить", role: .destructive) {
                Task {
                    await vm.revoke(s)
                    revokeTarget = nil
                }
            }
            Button("Отмена", role: .cancel) { revokeTarget = nil }
        }
    }
}

struct SessionRow: View {
    let session: SessionDTO
    var body: some View {
        VStack(alignment: .leading, spacing: OKSpacing.xs) {
            HStack {
                Label(session.deviceName, systemImage: icon)
                    .font(OKFont.bodyBold)
                Spacer()
                if session.isCurrent {
                    Text("Текущая")
                        .font(OKFont.caption)
                        .foregroundStyle(OKColor.success)
                        .padding(.horizontal, OKSpacing.s)
                        .padding(.vertical, OKSpacing.xxs)
                        .background(Capsule().fill(OKColor.success.opacity(0.15)))
                }
            }
            Text("IP \(session.ipAddress) • активна \(session.lastActiveAt, style: .relative)")
                .font(OKFont.caption)
                .foregroundStyle(OKColor.textSecondary)
        }
        .padding(.vertical, OKSpacing.xs)
    }

    private var icon: String {
        switch session.deviceType.lowercased() {
        case "ios", "iphone", "ipad": return "iphone"
        case "macos", "mac": return "laptopcomputer"
        case "android": return "phone.fill"
        case "web", "browser": return "globe"
        default: return "questionmark.app"
        }
    }
}
