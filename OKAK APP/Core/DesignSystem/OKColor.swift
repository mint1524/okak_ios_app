
import SwiftUI

enum OKColor {
    static let accent = Color(red: 0.141, green: 0.827, blue: 0.933)       // #24d3ee
    static let accentDeep = Color(red: 0.043, green: 0.220, blue: 0.271)  // #0b3845
    static let accentMid = Color(red: 0.035, green: 0.369, blue: 0.439)   // #095e70

    static let background = Color(light: .white, dark: Color(red: 0.043, green: 0.220, blue: 0.271))
    static let surface = Color(light: Color(white: 0.97), dark: Color(red: 0.035, green: 0.369, blue: 0.439))
    static let surfaceElevated = Color(light: .white, dark: Color(red: 0.043, green: 0.220, blue: 0.271).opacity(0.7))

    static let textPrimary = Color(light: Color(red: 0.043, green: 0.220, blue: 0.271), dark: .white)
    static let textSecondary = Color(light: Color(red: 0.035, green: 0.369, blue: 0.439), dark: Color(white: 0.7))
    static let textTertiary = Color(light: Color(white: 0.55), dark: Color(red: 0.141, green: 0.827, blue: 0.933).opacity(0.6))

    static let separator = Color(light: Color(red: 0.141, green: 0.827, blue: 0.933).opacity(0.3), dark: Color(red: 0.035, green: 0.369, blue: 0.439))

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
