import SwiftUI

struct MetadataDisplayView: View {
    @ObservedObject var viewModel: ImageProcessorViewModel

    var groupedMetadata: [MetadataCategory: [ExifMetadata]] {
        Dictionary(grouping: viewModel.metadata, by: { $0.category })
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppTheme.sectionSpacing) {
                    if let image = viewModel.originalImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: AppTheme.elementSpacing) {
                        HStack {
                            Text("Metadata Found")
                                .font(.theme.headline)
                                .foregroundColor(Color.theme.textPrimary)

                            Spacer()

                            Text("\(viewModel.metadata.count) items")
                                .font(.theme.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }

                        Text("This information will be removed")
                            .font(.theme.caption)
                            .foregroundColor(Color.theme.textSecondary)
                    }

                    ForEach(MetadataCategory.allCases, id: \.self) { category in
                        if let items = groupedMetadata[category], !items.isEmpty {
                            MetadataCategorySection(category: category, items: items)
                        }
                    }
                }
                .padding(AppTheme.screenPadding)
            }

            VStack(spacing: AppTheme.elementSpacing) {
                Divider()
                    .background(Color.theme.border)

                PurgeButton(isProcessing: viewModel.isProcessing) {
                    Task {
                        await viewModel.purgeMetadata()
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, AppTheme.screenPadding)
            }
            .background(Color.theme.background)
        }
    }
}
