
import SwiftUI

struct ChatDetailView: View {
    @StateObject var vm: ChatDetailViewModel
    @State private var showParameters = false
    @State private var showRename = false
    @State private var renameDraft: String = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            messageList
            inputBar
        }
        .navigationTitle(vm.chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        renameDraft = vm.chat.title
                        showRename = true
                    } label: { Label("Переименовать", systemImage: "pencil") }
                    Button {
                        showParameters = true
                    } label: { Label("Параметры", systemImage: "slider.horizontal.3") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task { await vm.load() }
        .alert("Переименовать чат", isPresented: $showRename) {
            TextField("Название", text: $renameDraft)
            Button("Сохранить") {
                Task { await vm.rename(to: renameDraft) }
            }
            Button("Отмена", role: .cancel) {}
        }
        .sheet(isPresented: $showParameters) {
            ChatParametersView(chat: vm.chat) { params in
                Task { await vm.applyParameters(params) }
            }
            .presentationDetents([.medium])
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: OKSpacing.m) {
                    if let quota = vm.quota {
                        QuotaBadgeView(quota: quota)
                            .padding(.horizontal, OKSpacing.l)
                            .padding(.top, OKSpacing.s)
                    }
                    if vm.messages.isEmpty {
                        EmptyChatView().padding(.top, OKSpacing.xxxl)
                    }
                    ForEach(vm.messages) { msg in
                        MessageBubbleView(message: msg)
                            .id(msg.id)
                    }
                    if let err = vm.errorMessage {
                        Text(err)
                            .font(OKFont.footnote)
                            .foregroundStyle(OKColor.danger)
                            .padding(.horizontal, OKSpacing.l)
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.vertical, OKSpacing.s)
            }
            .background(OKColor.background)
            .onChange(of: vm.messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .onChange(of: vm.messages.last?.content) { _, _ in
                proxy.scrollTo("bottom", anchor: .bottom)
            }
            .onChange(of: vm.messages.last?.status) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom, spacing: OKSpacing.s) {
                TextField("Сообщение", text: $vm.draft, axis: .vertical)
                    .lineLimit(1...6)
                    .focused($inputFocused)
                    .padding(.horizontal, OKSpacing.m)
                    .padding(.vertical, OKSpacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: OKRadius.l)
                            .fill(OKColor.surface)
                    )
                Button {
                    Task { await vm.send() }
                } label: {
                    Image(systemName: vm.isSending ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(vm.isSending || vm.canSend ? OKColor.accent : OKColor.textTertiary)
                }
                .disabled(!vm.canSend && !vm.isSending)
            }
            .padding(OKSpacing.s)
            .background(OKColor.background)
        }
    }
}

struct EmptyChatView: View {
    var body: some View {
        VStack(spacing: OKSpacing.s) {
            Image(systemName: "sparkles")
                .resizable().scaledToFit().frame(width: 48, height: 48)
                .foregroundStyle(OKColor.accent)
            Text("Спросите OKAK что угодно")
                .font(OKFont.title3)
            Text("AI учитывает контекст диалога и ваши предпочтения.")
                .font(OKFont.footnote)
                .foregroundStyle(OKColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(OKSpacing.l)
    }
}
