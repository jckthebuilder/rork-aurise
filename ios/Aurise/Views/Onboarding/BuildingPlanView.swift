import SwiftUI

struct BuildingPlanView: View {
    let onComplete: () -> Void
    @State private var progress: Double = 0
    @State private var currentStepIndex: Int = 0
    @State private var completedSteps: Set<Int> = []
    @State private var displayPercent: Int = 0

    private let steps = [
        "Configuring your goals",
        "Setting your mission",
        "Setting alarm tone",
        "Scheduling your alarm",
        "Finalizing wake-up plan"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Text("\(displayPercent)%")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(AuriseTheme.primaryText)
                    .contentTransition(.numericText(value: Double(displayPercent)))
                    .animation(.spring(response: 0.3), value: displayPercent)

                Text("Setting everything up\nfor you")
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AuriseTheme.primaryText)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AuriseTheme.subtleFill)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(AuriseTheme.accentGradient)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.spring(response: 0.4), value: progress)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 40)

                if currentStepIndex < steps.count {
                    Text(steps[currentStepIndex] + "...")
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .transition(.opacity)
                        .id("step-\(currentStepIndex)")
                }

                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 14) {
                            Text(step)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(
                                    completedSteps.contains(index) ? AuriseTheme.primaryText :
                                    index == currentStepIndex ? AuriseTheme.primaryText.opacity(0.8) :
                                    AuriseTheme.tertiaryText
                                )

                            Spacer()

                            ZStack {
                                if completedSteps.contains(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(AuriseTheme.accent)
                                        .transition(.scale.combined(with: .opacity))
                                } else {
                                    Circle()
                                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 1.5)
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .frame(width: 28, height: 28)
                        }
                        .padding(.vertical, 13)

                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(AuriseTheme.divider)
                                .frame(height: 1)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AuriseTheme.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(AuriseTheme.subtleBorder, lineWidth: 0.5)
                )
                .padding(.horizontal, 24)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            runAnimation()
        }
    }

    private func runAnimation() {
        let stepDuration = 0.6
        for i in 0..<steps.count {
            let delay = Double(i) * stepDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStepIndex = i
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + stepDuration * 0.7) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    _ = completedSteps.insert(i)
                }
            }
        }

        let totalDuration = Double(steps.count) * stepDuration
        let percentSteps = 50
        for i in 1...percentSteps {
            let t = totalDuration * Double(i) / Double(percentSteps)
            DispatchQueue.main.asyncAfter(deadline: .now() + t) {
                withAnimation(.spring(response: 0.2)) {
                    displayPercent = Int(100.0 * Double(i) / Double(percentSteps))
                    progress = Double(i) / Double(percentSteps)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 0.5) {
            onComplete()
        }
    }
}
