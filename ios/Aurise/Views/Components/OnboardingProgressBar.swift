import SwiftUI

struct OnboardingProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AuriseTheme.subtleFill)

                Capsule()
                    .fill(AuriseTheme.accentGradient)
                    .frame(width: max(geo.size.width * progress, 6))
                    .shadow(color: AuriseTheme.accentGlow.opacity(0.5), radius: 8, y: 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 24)
    }
}
