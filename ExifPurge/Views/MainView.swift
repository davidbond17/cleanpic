import SwiftUI
import PhotosUI

struct MainView: View {
    @StateObject private var viewModel = ImageProcessorViewModel()
    @State private var isPhotosPickerPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.05),
                        Color(red: 0.05, green: 0.05, blue: 0.08)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                PHPickerViewControllerWrapper(
                    isPresented: $isPhotosPickerPresented,
                    onImagesSelected: { images in
                        viewModel.loadImages(images)
                    }
                )
                .frame(width: 0, height: 0)

                if viewModel.originalImage == nil && viewModel.batchPhotos.isEmpty {
                    EmptyStateContent(isPhotosPickerPresented: $isPhotosPickerPresented)
                } else if viewModel.isBatchMode {
                    BatchMetadataDisplayView(viewModel: viewModel)
                } else {
                    MetadataDisplayView(viewModel: viewModel)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.theme.accentBlue)

                        Text("ExifPurge")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                }

                if viewModel.originalImage != nil || !viewModel.batchPhotos.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.reset()
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
            }
            .alert("Metadata Purged Successfully", isPresented: $viewModel.showDeleteOriginalAlert) {
                Button("Delete Original\(viewModel.isBatchMode ? "s" : "")", role: .destructive) {
                    Task {
                        await viewModel.deleteOriginalPhoto()
                    }
                }
                Button("Keep Both") {
                    viewModel.reset()
                }
            } message: {
                if viewModel.isBatchMode {
                    Text("All clean photos have been saved. Would you like to delete the \(viewModel.batchPhotos.count) original photos with metadata?\n\nThe clean copies are identical except without any metadata.")
                } else {
                    Text("Your clean photo has been saved. Would you like to delete the original photo with metadata?\n\nThe clean copy is identical except without any metadata.")
                }
            }
            .alert("Success", isPresented: $viewModel.showDeletionSuccessAlert) {
                Button("OK") {
                    viewModel.reset()
                }
            } message: {
                Text(viewModel.successMessage)
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct EmptyStateContent: View {
    @Binding var isPhotosPickerPresented: Bool
    @State private var glowAnimation = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 20)

                ZStack {
                    Circle()
                        .fill(Color.theme.accentGlow)
                        .frame(width: 140, height: 140)
                        .blur(radius: 30)
                        .scaleEffect(glowAnimation ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.accentBlue, Color.theme.accentBlue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.theme.accentBlue.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .onAppear {
                    glowAnimation = true
                }

                VStack(spacing: 12) {
                    Text("ExifPurge")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundColor(.white)

                    Text("Privacy-First Metadata Removal")
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundColor(Color.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 16) {
                    FeatureCard(
                        icon: "photo.on.rectangle.angled",
                        title: "Select",
                        description: "Choose a photo to analyze",
                        color: .blue
                    )

                    FeatureCard(
                        icon: "eye.fill",
                        title: "Inspect",
                        description: "View all hidden metadata",
                        color: .purple
                    )

                    FeatureCard(
                        icon: "trash.fill",
                        title: "Purge",
                        description: "Remove with one tap",
                        color: .pink
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    isPhotosPickerPresented = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus.fill")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Select Photo")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.theme.accentBlue,
                                    Color(red: 0.02, green: 0.4, blue: 0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )

                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.theme.accentBlue.opacity(0.5), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer(minLength: 20)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(Color.theme.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    MainView()
}
