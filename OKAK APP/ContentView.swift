
import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("OKAK")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
            Text("AI Mobile")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RootView()
}
