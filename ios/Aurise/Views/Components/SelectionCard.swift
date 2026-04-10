import SwiftUI

struct SelectionCard: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    init(_ title: String, subtitle: String? = nil, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let icon {
                    ZStack {
                        Circle()
                            .fill(isSelected ? AuriseTheme.accent.opacity(0.2) : AuriseTheme.subtleFill)
                            .frame(width: 42, height: 42)

                        Image(systemName: icon)
                            .font(.body.weight(.medium))
                            .foregroundStyle(isSelected ? AuriseTheme.accent : AuriseTheme.secondaryText)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isSelected ? AuriseTheme.primaryText : AuriseTheme.primaryText.opacity(0.85))

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(isSelected ? AuriseTheme.accentSoft : AuriseTheme.secondaryText)
                            .lineLimit(2)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? .clear : AuriseTheme.radioUnselected, lineWidth: 1.5)
                        .background(
                            Circle().fill(isSelected ? AuriseTheme.accent : .clear)
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AuriseTheme.cardSelectedFill : AuriseTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? AuriseTheme.cardSelectedBorder : AuriseTheme.subtleBorder, lineWidth: isSelected ? 1.5 : 0.5)
            )
            .shadow(color: isSelected ? AuriseTheme.accentGlow.opacity(0.15) : .clear, radius: 12, y: 4)
        }
        .buttonStyle(CardButtonStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSelected)
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
