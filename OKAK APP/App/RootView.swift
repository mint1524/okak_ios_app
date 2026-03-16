
import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: OKSpacing.m) {
            Text("OKAK")
                .font(OKFont.brand)
                .foregroundStyle(OKColor.accent)
            Text("AI Mobile")
                .font(OKFont.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OKColor.background.ignoresSafeArea())
    }
}

#Preview {
    RootView()
}
