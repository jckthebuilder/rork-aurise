import SwiftUI

struct AffirmationsMissionView: View {
    let onComplete: () -> Void

    @State private var affirmations: [String] = []
    @State private var currentIndex: Int = 0
    @State private var isLoading: Bool = true
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding: Bool = false
    @State private var confirmed: [Bool] = []
    @State private var completed: Bool = false
    @State private var holdTimer: Timer? = nil

    private let accentColor = MissionType.affirmations.accentColor
    private let holdDuration: Double = 2.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if completed {
                completionView
            } else if currentIndex < affirmations.count {
                affirmationView
            }
        }
        .task { await loadAffirmations() }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(accentColor)
                .scaleEffect(1.2)
            Text("Creating your affirmations...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: completed)
            Text("Mission Complete")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text("You're ready to own this day.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .transition(.scale.combined(with: .opacity))
    }

    private var affirmationView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("AFFIRMATIONS")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(2)
                Spacer()
                Text("\(currentIndex + 1) of \(affirmations.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            GeometryReader { geo in
                let barWidth = geo.size.width * (Double(currentIndex) / Double(affirmations.count))
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 4)
                    Capsule().fill(accentColor).frame(width: max(0, barWidth), height: 4)
                        .animation(.spring, value: currentIndex)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer()

            VStack(spacing: 32) {
                HStack(spacing: 6) {
                    ForEach(0..<affirmations.count, id: \.self) { i in
                        Circle()
                            .fill(i < currentIndex ? accentColor : (i == currentIndex ? accentColor.opacity(0.5) : .white.opacity(0.15)))
                            .frame(width: 8, height: 8)
                    }
                }

                Text(affirmations[currentIndex])
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .id(currentIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                Text("Read aloud, then hold to confirm")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Image(systemName: holdProgress >= 1 ? "checkmark" : "hand.tap.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(holdProgress >= 1 ? .green : accentColor)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHolding { startHold() }
                    }
                    .onEnded { _ in
                        stopHold()
                    }
            )
            .sensoryFeedback(.impact(weight: .light), trigger: isHolding)

            Spacer().frame(height: 60)
        }
    }

    private func startHold() {
        isHolding = true
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.linear(duration: 0.02)) {
                    holdProgress += CGFloat(0.02 / holdDuration)
                }
                if holdProgress >= 1.0 {
                    holdTimer?.invalidate()
                    holdTimer = nil
                    confirmAffirmation()
                }
            }
        }
    }

    private func stopHold() {
        isHolding = false
        holdTimer?.invalidate()
        holdTimer = nil
        if holdProgress < 1.0 {
            withAnimation(.spring(response: 0.3)) {
                holdProgress = 0
            }
        }
    }

    private func confirmAffirmation() {
        if currentIndex + 1 >= affirmations.count {
            withAnimation(.spring) { completed = true }
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                onComplete()
            }
        } else {
            Task {
                try? await Task.sleep(for: .seconds(0.3))
                withAnimation(.spring(response: 0.4)) {
                    currentIndex += 1
                    holdProgress = 0
                }
            }
        }
    }

    private func loadAffirmations() async {
        isLoading = true
        let generated = await AIService.shared.generateAffirmations()
        affirmations = generated
        confirmed = Array(repeating: false, count: generated.count)
        isLoading = false
    }
}
