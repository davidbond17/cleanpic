import SwiftUI

struct MetadataCard: View {
    let metadata: ExifMetadata

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metadata.displayName)
                .font(.theme.metadataKey)
                .foregroundColor(Color.theme.accentBlue)

            Text(metadata.value)
                .font(.theme.metadataValue)
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.cardPadding)
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.theme.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(metadata.displayName): \(metadata.value)")
    }
}
