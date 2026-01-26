import SwiftUI

struct PurgeButton: View {
    let isProcessing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .semibold))
                }

                Text(isProcessing ? "Purging..." : "Purge Metadata")
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
        .disabled(isProcessing)
        .animation(.easeInOut(duration: AppTheme.animationDuration), value: isProcessing)
        .accessibilityLabel(isProcessing ? "Purging metadata" : "Purge metadata from image")
        .accessibilityHint("Removes all metadata and saves a clean copy to your photo library")
    }
}

#Preview {
    VStack(spacing: 20) {
        PurgeButton(isProcessing: false) {}
        PurgeButton(isProcessing: true) {}
    }
    .padding()
    .background(Color.theme.background)
    .preferredColorScheme(.dark)
}
