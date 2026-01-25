import SwiftUI
import PhotosUI

struct MainView: View {
    @StateObject private var viewModel = ImageProcessorViewModel()
    @State private var isPhotosPickerPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                if viewModel.originalImage == nil {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        Spacer()

                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.theme.accentBlue)

                        VStack(spacing: AppTheme.elementSpacing) {
                            Text("ExifPurge")
                                .font(.theme.title)
                                .foregroundColor(Color.theme.textPrimary)

                            Text("Privacy-First Metadata Removal")
                                .font(.theme.subheadline)
                                .foregroundColor(Color.theme.textSecondary)
                        }

                        VStack(spacing: AppTheme.elementSpacing) {
                            InstructionRow(
                                icon: "photo.on.rectangle.angled",
                                text: "Select a photo to analyze"
                            )

                            InstructionRow(
                                icon: "eye.fill",
                                text: "View all hidden metadata"
                            )

                            InstructionRow(
                                icon: "trash.fill",
                                text: "Purge with one tap"
                            )
                        }
                        .padding(.top, AppTheme.sectionSpacing)

                        Button(action: {
                            isPhotosPickerPresented = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 18, weight: .semibold))

                                Text("Select Photo")
                                    .font(.theme.button)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.buttonHeight)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.theme.accentBlue,
                                        Color.theme.accentBlue.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius))
                        }
                        .padding(.horizontal, AppTheme.screenPadding)
                        .padding(.top, AppTheme.sectionSpacing)

                        Spacer()
                        Spacer()
                    }
                    .padding(AppTheme.screenPadding)
                } else {
                    MetadataDisplayView(viewModel: viewModel)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ExifPurge")
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.textPrimary)
                }

                if viewModel.originalImage != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.reset()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
            }
            .photosPicker(
                isPresented: $isPhotosPickerPresented,
                selection: $viewModel.selectedImageItem,
                matching: .images
            )
            .onChange(of: viewModel.selectedImageItem) { oldValue, newValue in
                if let newValue {
                    Task {
                        await viewModel.loadImage(from: newValue)
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    viewModel.reset()
                }
            } message: {
                Text("Image saved to your library without metadata.")
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

#Preview {
    MainView()
}
