import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color(red: 0.05, green: 0.05, blue: 0.05)
    let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.17)
    let textPrimary = Color.white
    let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7)
    let accentBlue = Color(red: 0.04, green: 0.52, blue: 1.0)
    let success = Color.green
    let error = Color.red
    let border = Color.white.opacity(0.15)

    let accentGlow = Color(red: 0.04, green: 0.52, blue: 1.0).opacity(0.3)
    let darkOverlay = Color.black.opacity(0.3)
}
