
import SwiftUI

struct MessageBubbleView: View {
    let message: MessageDTO

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: OKSpacing.xxl) }
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: OKSpacing.xs) {
                bubbleBody
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

    private var bubbleBody: some View {
        VStack(alignment: .leading, spacing: OKSpacing.s) {
            if !message.content.isEmpty {
                Text(renderedContent)
                    .font(OKFont.body)
                    .foregroundStyle(textColor)
            }
            if message.status == .streaming {
                HStack(spacing: OKSpacing.xs) {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(message.role == .user ? Color.white.opacity(0.7) : OKColor.textSecondary)
                    if message.content.isEmpty {
                        Text("OKAK печатает...")
                            .font(OKFont.caption)
                            .foregroundStyle(message.role == .user ? Color.white.opacity(0.7) : OKColor.textSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, OKSpacing.l)
        .padding(.vertical, OKSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: OKRadius.l, style: .continuous)
                .fill(background)
        )
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

    private var renderedContent: AttributedString {
        (try? AttributedString(markdown: message.content)) ?? AttributedString(message.content)
    }
}
