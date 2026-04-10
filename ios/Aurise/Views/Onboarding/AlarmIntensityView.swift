import SwiftUI

struct AlarmIntensityView: View {
    @Binding var selection: AlarmIntensity?
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How intense should\nyour alarm feel?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AuriseTheme.primaryText)
                            .lineSpacing(3)

                        Text("You know yourself best.")
                            .font(.subheadline)
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }
                    .padding(.top, 28)

                    VStack(spacing: 12) {
                        ForEach(Array(AlarmIntensity.allCases.enumerated()), id: \.element) { index, intensity in
                            SelectionCard(
                                intensity.rawValue,
                                subtitle: intensity.subtitle,
                                icon: intensity.icon,
                                isSelected: selection == intensity
                            ) {
                                selection = intensity
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.08), value: appeared)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            PrimaryCTAButton("Continue", enabled: selection != nil, action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}
