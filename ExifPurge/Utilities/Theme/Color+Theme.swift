import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color("BackgroundDark")
    let cardBackground = Color("CardBackground")
    let textPrimary = Color("TextPrimary")
    let textSecondary = Color("TextSecondary")
    let accentBlue = Color("AccentBlue")
    let success = Color.green
    let error = Color.red
    let border = Color.white.opacity(0.1)
}
