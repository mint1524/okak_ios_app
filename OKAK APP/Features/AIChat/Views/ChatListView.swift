
import SwiftUI

struct ChatListView: View {
    @StateObject var vm: ChatListViewModel
    @State private var pushChat: ChatDTO?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("AI Chat")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                if let chat = await vm.createChat() { pushChat = chat }
                            }
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
                .refreshable { await vm.refresh() }
                .task { await vm.refresh() }
                .navigationDestination(item: $pushChat) { chat in
                    ChatDetailView(vm: ChatDetailViewModel(chat: chat, service: vm.service))
                }
                .navigationDestination(for: ChatDTO.self) { chat in
                    ChatDetailView(vm: ChatDetailViewModel(chat: chat, service: vm.service))
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.chats.isEmpty {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.chats.isEmpty {
            VStack(spacing: OKSpacing.m) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .resizable().scaledToFit().frame(width: 64, height: 64)
                    .foregroundStyle(OKColor.textTertiary)
                Text("Пока нет чатов")
                    .font(OKFont.title2)
                Text("Нажмите на иконку, чтобы создать первый диалог.")
                    .font(OKFont.footnote)
                    .foregroundStyle(OKColor.textSecondary)
                    .multilineTextAlignment(.center)
                Button {
                    Task {
                        if let chat = await vm.createChat() { pushChat = chat }
                    }
                } label: { Text("Новый чат") }
                .buttonStyle(OKPrimaryButtonStyle())
                .frame(maxWidth: 240)
            }
            .padding(OKSpacing.l)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                if let quota = vm.quota {
                    QuotaBadgeView(quota: quota)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                ForEach(vm.chats) { chat in
                    NavigationLink(value: chat) {
                        ChatRowView(chat: chat)
                    }
                }
                .onDelete { indexSet in
                    Task {
                        for idx in indexSet { await vm.delete(vm.chats[idx]) }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct ChatRowView: View {
    let chat: ChatDTO
    var body: some View {
        VStack(alignment: .leading, spacing: OKSpacing.xs) {
            Text(chat.title)
                .font(OKFont.bodyBold)
                .lineLimit(1)
            HStack(spacing: OKSpacing.s) {
                Text(chat.model)
                Text("•")
                Text(chat.updatedAt, style: .relative)
            }
            .font(OKFont.caption)
            .foregroundStyle(OKColor.textSecondary)
        }
        .padding(.vertical, OKSpacing.xs)
    }
}

struct QuotaBadgeView: View {
    let quota: QuotaDTO
    var body: some View {
        HStack(spacing: OKSpacing.s) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(OKColor.warning)
            Text("\(quota.remaining) из \(quota.limit) запросов осталось — \(quota.planName)")
                .font(OKFont.footnote)
                .foregroundStyle(OKColor.textSecondary)
        }
        .padding(.vertical, OKSpacing.s)
    }
}
