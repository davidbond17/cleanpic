import SwiftUI

struct BatchMetadataDisplayView: View {
    @ObservedObject var viewModel: ImageProcessorViewModel
    @State private var expandedPhotoIds: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    BatchSummaryCard(
                        photoCount: viewModel.batchPhotos.count,
                        metadataCount: viewModel.totalMetadataCount
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    if viewModel.isProcessing {
                        ProgressCard(
                            status: viewModel.processingStatus,
                            progress: viewModel.processingProgress
                        )
                        .padding(.horizontal, 20)
                    }

                    ForEach(viewModel.batchPhotos) { photo in
                        CollapsiblePhotoRow(
                            photo: photo,
                            isExpanded: expandedPhotoIds.contains(photo.id),
                            onToggle: {
                                if expandedPhotoIds.contains(photo.id) {
                                    expandedPhotoIds.remove(photo.id)
                                } else {
                                    expandedPhotoIds.insert(photo.id)
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }

            VStack(spacing: 0) {
                Divider()
                    .background(Color.white.opacity(0.15))

                EnhancedPurgeButton(isProcessing: viewModel.isProcessing) {
                    Task {
                        await viewModel.purgeMetadata()
                    }
                }
                .padding(20)
            }
            .background(
                Color(red: 0.08, green: 0.08, blue: 0.10)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.05),
                    Color(red: 0.05, green: 0.05, blue: 0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct BatchSummaryCard: View {
    let photoCount: Int
    let metadataCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "photo.stack.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)

                Text("\(photoCount) Photos Selected")
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Spacer()
            }

            HStack {
                Text("\(metadataCount) metadata items total")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))

                Spacer()

                Text("Sorted by metadata count")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

struct ProgressCard: View {
    let status: String
    let progress: Double

    var body: some View {
        VStack(spacing: 12) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))

            Text(status)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

struct CollapsiblePhotoRow: View {
    let photo: BatchPhotoItem
    let isExpanded: Bool
    let onToggle: () -> Void

    var groupedMetadata: [MetadataCategory: [ExifMetadata]] {
        Dictionary(grouping: photo.metadata, by: { $0.category })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if !photo.metadata.isEmpty {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.orange)
                            } else {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.green)
                            }

                            Text("\(photo.metadataCount) items")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                        }

                        if !photo.metadata.isEmpty {
                            let categories = Set(photo.metadata.map { $0.category })
                            HStack(spacing: 8) {
                                ForEach(Array(categories).prefix(4), id: \.self) { category in
                                    CategoryBadge(category: category)
                                }
                                if categories.count > 4 {
                                    Text("+\(categories.count - 4)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                        .padding(.leading, 4)
                                }
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded && !photo.metadata.isEmpty {
                VStack(spacing: 16) {
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    ForEach(MetadataCategory.allCases, id: \.self) { category in
                        if let items = groupedMetadata[category], !items.isEmpty {
                            CategoryMetadataSection(category: category, items: items)
                        }
                    }
                }
                .padding(16)
                .background(Color(red: 0.08, green: 0.08, blue: 0.10))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

struct CategoryBadge: View {
    let category: MetadataCategory

    var categoryColor: Color {
        switch category {
        case .location: return .red
        case .device: return .blue
        case .camera: return .purple
        case .dateTime: return .orange
        case .software: return .green
        case .other: return .gray
        }
    }

    var categoryIcon: String {
        switch category {
        case .location: return "location.fill"
        case .device: return "iphone"
        case .camera: return "camera.fill"
        case .dateTime: return "clock.fill"
        case .software: return "gear"
        case .other: return "info.circle.fill"
        }
    }

    var body: some View {
        Image(systemName: categoryIcon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(categoryColor)
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(categoryColor.opacity(0.4), lineWidth: 1)
                    )
            )
    }
}

struct CategoryMetadataSection: View {
    let category: MetadataCategory
    let items: [ExifMetadata]

    var categoryColor: Color {
        switch category {
        case .location: return .red
        case .device: return .blue
        case .camera: return .purple
        case .dateTime: return .orange
        case .software: return .green
        case .other: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.rawValue)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(categoryColor)
                .textCase(.uppercase)

            ForEach(items) { metadata in
                CompactMetadataRow(metadata: metadata, color: categoryColor)
            }
        }
    }
}

struct CompactMetadataRow: View {
    let metadata: ExifMetadata
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(metadata.displayName)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(color)

            Spacer()

            Text(metadata.value)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}
