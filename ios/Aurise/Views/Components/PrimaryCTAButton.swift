import SwiftUI

struct PrimaryCTAButton: View {
    let title: String
    let enabled: Bool
    let action: () -> Void

    init(_ title: String, enabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.enabled = enabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .tracking(0.3)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(enabled ? AuriseTheme.accentGradient : LinearGradient(colors: [AuriseTheme.disabledFill], startPoint: .leading, endPoint: .trailing))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(enabled ? AuriseTheme.buttonOverlay : Color.clear, lineWidth: 0.5)
                )
                .shadow(color: enabled ? AuriseTheme.accentGlow.opacity(0.4) : .clear, radius: 20, y: 8)
        }
        .disabled(!enabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: enabled)
    }
}
