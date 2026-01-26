import SwiftUI

struct MetadataCategorySection: View {
    let category: MetadataCategory
    let items: [ExifMetadata]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.elementSpacing) {
            HStack {
                Text(category.rawValue)
                    .font(.theme.headline)
                    .foregroundColor(Color.theme.textPrimary)

                Spacer()

                Text("\(items.count)")
                    .font(.theme.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.theme.accentBlue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            ForEach(items) { metadata in
                MetadataCard(metadata: metadata)
            }
        }
    }
}
