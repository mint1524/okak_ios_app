
import SwiftUI

struct MessageBubbleView: View {
    let message: MessageDTO

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: OKSpacing.xxl) }
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: OKSpacing.xs) {
                Text(message.content)
                    .font(OKFont.body)
                    .foregroundStyle(textColor)
                    .padding(.horizontal, OKSpacing.l)
                    .padding(.vertical, OKSpacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: OKRadius.l, style: .continuous)
                            .fill(background)
                    )
                if message.status == .streaming {
                    HStack(spacing: OKSpacing.xs) {
                        ProgressView()
                            .controlSize(.small)
                            .tint(OKColor.textSecondary)
                        Text("OKAK печатает...")
                            .font(OKFont.caption)
                            .foregroundStyle(OKColor.textSecondary)
                    }
                    .padding(.leading, OKSpacing.l)
                }
                if !message.attachments.isEmpty {
                    HStack(spacing: OKSpacing.xs) {
                        ForEach(message.attachments) { att in
                            Label(att.name, systemImage: "paperclip")
                                .font(OKFont.caption)
                                .foregroundStyle(OKColor.textSecondary)
                        }
                    }
                }
                if message.status == .failed {
                    Text("Не удалось получить ответ")
                        .font(OKFont.caption)
                        .foregroundStyle(OKColor.danger)
                }
            }
            if message.role != .user { Spacer(minLength: OKSpacing.xxl) }
        }
        .padding(.horizontal, OKSpacing.l)
    }

    private var cursor: String {
        "" 
    }

    private var background: Color {
        switch message.role {
        case .user: return OKColor.accent
        case .assistant: return OKColor.surface
        case .system: return OKColor.surfaceElevated
        }
    }

    private var textColor: Color {
        message.role == .user ? .white : OKColor.textPrimary
    }
}
