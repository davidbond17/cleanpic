import SwiftUI

struct MetadataDisplayView: View {
    @ObservedObject var viewModel: ImageProcessorViewModel

    var groupedMetadata: [MetadataCategory: [ExifMetadata]] {
        Dictionary(grouping: viewModel.metadata, by: { $0.category })
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    if let image = viewModel.originalImage {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.3))
                                .frame(height: 220)

                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.orange)

                            Text("Metadata Detected")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(viewModel.metadata.count)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(minWidth: 36, minHeight: 36)
                                .background(
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .overlay(
                                            Circle()
                                                .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                                        )
                                )
                        }

                        Text("This information can reveal your location, device, and personal data")
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.15, green: 0.12, blue: 0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                    .padding(.horizontal, 20)

                    if !viewModel.metadata.isEmpty {
                        ForEach(MetadataCategory.allCases, id: \.self) { category in
                            if let items = groupedMetadata[category], !items.isEmpty {
                                EnhancedMetadataCategorySection(category: category, items: items)
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)

                            Text("No Metadata Found")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            Text("This image appears to be clean")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
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

struct EnhancedMetadataCategorySection: View {
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: categoryIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(categoryColor)
                }

                Text(category.rawValue)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Spacer()

                Text("\(items.count)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(categoryColor.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(categoryColor.opacity(0.4), lineWidth: 1)
                            )
                    )
            }

            VStack(spacing: 10) {
                ForEach(items) { metadata in
                    EnhancedMetadataCard(metadata: metadata, categoryColor: categoryColor)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct EnhancedMetadataCard: View {
    let metadata: ExifMetadata
    let categoryColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metadata.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(categoryColor)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()
            }

            Text(metadata.value)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(categoryColor.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct EnhancedPurgeButton: View {
    let isProcessing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20, weight: .bold))
                }

                Text(isProcessing ? "Purging Metadata..." : "Purge All Metadata")
                    .font(.system(size: 18, weight: .bold, design: .default))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.red.opacity(0.8),
                            Color.red.opacity(0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.red.opacity(0.4), radius: 15, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(isProcessing)
        .opacity(isProcessing ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
        .accessibilityLabel(isProcessing ? "Purging metadata" : "Purge metadata from image")
        .accessibilityHint("Removes all metadata and saves a clean copy to your photo library")
    }
}
