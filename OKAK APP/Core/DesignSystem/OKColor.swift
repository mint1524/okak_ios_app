
import SwiftUI

enum OKColor {
    static let accent = Color("AccentColor")

    static let background = Color(light: .white, dark: Color(red: 0.06, green: 0.06, blue: 0.08))
    static let surface = Color(light: Color(white: 0.97), dark: Color(white: 0.12))
    static let surfaceElevated = Color(light: .white, dark: Color(white: 0.16))

    static let textPrimary = Color(light: .black, dark: .white)
    static let textSecondary = Color(light: Color(white: 0.35), dark: Color(white: 0.7))
    static let textTertiary = Color(light: Color(white: 0.55), dark: Color(white: 0.55))

    static let separator = Color(light: Color(white: 0.9), dark: Color(white: 0.2))

    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let danger = Color(red: 0.95, green: 0.30, blue: 0.30)
    static let warning = Color(red: 0.98, green: 0.72, blue: 0.20)
}

private extension Color {
    init(light: Color, dark: Color) {
        self = Color(UIColor { trait in
            switch trait.userInterfaceStyle {
            case .dark: return UIColor(dark)
            default: return UIColor(light)
            }
        })
    }
}
