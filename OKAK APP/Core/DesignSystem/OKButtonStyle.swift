
import SwiftUI

struct OKPrimaryButtonStyle: ButtonStyle {
    var loading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .font(OKFont.bodyBold)
                .foregroundStyle(.white)
                .opacity(loading ? 0 : 1)
            if loading {
                ProgressView().tint(.white)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(
            RoundedRectangle(cornerRadius: OKRadius.m, style: .continuous)
                .fill(OKColor.accent.opacity(configuration.isPressed ? 0.85 : 1))
        )
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

struct OKSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(OKFont.bodyBold)
            .foregroundStyle(OKColor.accent)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: OKRadius.m, style: .continuous)
                    .stroke(OKColor.accent, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct OKTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(OKFont.body)
            .padding(.horizontal, OKSpacing.l)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: OKRadius.m, style: .continuous)
                    .fill(OKColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: OKRadius.m, style: .continuous)
                    .stroke(OKColor.separator, lineWidth: 1)
            )
    }
}
