import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.sectionSpacing) {
                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.theme.accentBlue)

                VStack(spacing: AppTheme.elementSpacing) {
                    Text("CleanPic")
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

                Spacer()
                Spacer()
            }
            .padding(AppTheme.screenPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.theme.background)
            .navigationBarHidden(true)
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppTheme.elementSpacing) {
            Image(systemName: icon)
                .font(.theme.body)
                .foregroundColor(Color.theme.accentBlue)
                .frame(width: 24)

            Text(text)
                .font(.theme.body)
                .foregroundColor(Color.theme.textSecondary)

            Spacer()
        }
    }
}

#Preview {
    EmptyStateView()
        .preferredColorScheme(.dark)
}
