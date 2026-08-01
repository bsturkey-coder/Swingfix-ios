import SwiftUI

struct ActionCard<Content: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let isPrimary: Bool
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        isPrimary: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isPrimary = isPrimary
        self.content = content()
    }

    var body: some View {
        content
            .buttonStyle(.plain)
            .overlay {
                HStack(spacing: 16) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .foregroundStyle(isPrimary ? .white : AppColors.accent)
                        .background(isPrimary ? Color.white.opacity(0.18) : AppColors.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(isPrimary ? .white.opacity(0.82) : .secondary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(isPrimary ? .white.opacity(0.8) : .tertiary)
                }
                .foregroundStyle(isPrimary ? .white : .primary)
                .padding(18)
            }
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(isPrimary ? AppColors.accent : AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
