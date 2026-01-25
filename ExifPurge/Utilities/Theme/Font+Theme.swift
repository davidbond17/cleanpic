import SwiftUI

extension Font {
    static let theme = FontTheme()
}

struct FontTheme {
    let title = Font.system(size: 32, weight: .bold, design: .default)
    let headline = Font.system(size: 20, weight: .semibold, design: .default)
    let subheadline = Font.system(size: 18, weight: .medium, design: .default)
    let body = Font.system(size: 16, weight: .regular, design: .default)
    let metadataKey = Font.system(size: 14, weight: .medium, design: .monospaced)
    let metadataValue = Font.system(size: 14, weight: .regular, design: .monospaced)
    let caption = Font.system(size: 12, weight: .regular, design: .default)
    let button = Font.system(size: 18, weight: .semibold, design: .default)
}
