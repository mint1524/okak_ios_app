
import SwiftUI

struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: OKSpacing.s) {
            Image(systemName: "wifi.slash")
            Text("Нет соединения с сетью")
                .font(OKFont.footnote)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, OKSpacing.s)
        .background(OKColor.danger)
    }
}
