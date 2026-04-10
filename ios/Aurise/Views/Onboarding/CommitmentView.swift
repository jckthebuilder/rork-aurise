import SwiftUI

struct CommitmentView: View {
    let targetTime: String
    let onActivate: () -> Void
    @State private var appeared = false
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var activated = false
    @State private var pulseRing = false

    private let holdDuration: Double = 2.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 44) {
                VStack(spacing: 16) {
                    Text("Your plan is ready.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AuriseTheme.primaryText)
                        .opacity(appeared ? 1 : 0)

                    Text("Hold to activate your\nmorning system")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AuriseTheme.secondaryText)
                        .opacity(appeared ? 1 : 0)
                }

                ZStack {
                    Circle()
                        .fill(AuriseTheme.accent.opacity(0.06))
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseRing ? 1.3 : 1.0)
                        .opacity(pulseRing ? 0 : 0.5)

                    Circle()
                        .fill(AuriseTheme.accent.opacity(0.04))
                        .frame(width: 180, height: 180)

                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(
                            AuriseTheme.accentGradient,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .fill(
                            activated ?
                            AnyShapeStyle(AuriseTheme.accentGradient) :
                            AnyShapeStyle(AuriseTheme.accent.opacity(isHolding ? 0.2 : 0.1))
                        )
                        .frame(width: 140, height: 140)

                    VStack(spacing: 6) {
                        if activated {
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(.white)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "sunrise.fill")
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(AuriseTheme.accent)

                            Text(targetTime)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AuriseTheme.accent.opacity(0.8))
                        }
                    }
                }
                .scaleEffect(isHolding ? 1.05 : 1.0)
                .animation(.spring(response: 0.3), value: isHolding)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.85)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !activated else { return }
                            if !isHolding {
                                isHolding = true
                                startHold()
                            }
                        }
                        .onEnded { _ in
                            guard !activated else { return }
                            isHolding = false
                            withAnimation(.spring(response: 0.3)) {
                                holdProgress = 0
                            }
                        }
                )

                if isHolding && !activated {
                    Text("Keep holding...")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AuriseTheme.accent)
                        .transition(.opacity)
                } else if !activated {
                    Text("Tap and hold to commit")
                        .font(.subheadline)
                        .foregroundStyle(AuriseTheme.tertiaryText)
                }
            }

            Spacer()
            Spacer()
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: activated)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseRing = true
            }
        }
    }

    private func startHold() {
        let steps = 60
        let interval = holdDuration / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                guard isHolding, !activated else { return }
                withAnimation(.linear(duration: interval)) {
                    holdProgress = CGFloat(i) / CGFloat(steps)
                }
                if i == steps {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        activated = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        onActivate()
                    }
                }
            }
        }
    }
}
