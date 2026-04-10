import SwiftUI

struct ReliabilityCheckView: View {
    @Binding var selection: SingleAlarmWorks?
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("If you only set one alarm,\nwould that actually work?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AuriseTheme.primaryText)
                            .lineSpacing(3)

                        Text("That's what we thought.")
                            .font(.subheadline)
                            .foregroundStyle(AuriseTheme.secondaryText)
                    }
                    .padding(.top, 28)

                    VStack(spacing: 12) {
                        ForEach(Array(SingleAlarmWorks.allCases.enumerated()), id: \.element) { index, option in
                            SelectionCard(
                                option.rawValue,
                                isSelected: selection == option
                            ) {
                                selection = option
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06), value: appeared)
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
