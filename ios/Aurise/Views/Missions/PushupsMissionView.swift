import SwiftUI
import CoreMotion

struct PushupsMissionView: View {
    let onComplete: () -> Void

    @State private var count: Int = 0
    @State private var completed: Bool = false
    @State private var motionManager = CMMotionManager()
    @State private var isDown: Bool = false
    @State private var lastY: Double = 0

    private let requiredCount = 10
    private let accentColor = MissionType.pushups.accentColor

    private var progress: Double {
        min(1.0, Double(count) / Double(requiredCount))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                HStack {
                    Text("PUSHUPS MISSION")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(2)
                    Spacer()
                    Text("\(count)/\(requiredCount)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 24)

                Spacer()

                if completed {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                            .symbolEffect(.bounce, value: completed)
                        Text("Mission Complete")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Energy unlocked. No going back to bed.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.08), lineWidth: 8)
                                .frame(width: 200, height: 200)

                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    AngularGradient(
                                        colors: [accentColor, accentColor.opacity(0.5), accentColor],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.3), value: count)

                            VStack(spacing: 4) {
                                Text("\(count)")
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .contentTransition(.numericText())
                                Text("pushups")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }

                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 32))
                            .foregroundStyle(accentColor)
                            .symbolEffect(.variableColor.iterative, isActive: !completed)

                        Text("Place your phone on the floor\nand start doing pushups!")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)

                        Text("The accelerometer detects your movement")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                Spacer()

                #if targetEnvironment(simulator)
                if !completed {
                    HStack(spacing: 12) {
                        Button {
                            registerPushup()
                        } label: {
                            Text("+1 Pushup")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(.white.opacity(0.12)))
                        }

                        Button {
                            for _ in 0..<5 { registerPushup() }
                        } label: {
                            Text("+5 Pushups")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(accentColor.opacity(0.3)))
                        }
                    }
                    .padding(.bottom, 24)
                }
                #endif
            }
            .padding(.top, 20)
        }
        .onAppear { startMotionDetection() }
        .onDisappear { motionManager.stopAccelerometerUpdates() }
        .sensoryFeedback(.impact(weight: .medium), trigger: count)
    }

    private func startMotionDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            guard let data, !completed else { return }
            let y = data.acceleration.y

            if !isDown && y < -0.6 {
                isDown = true
            } else if isDown && y > 0.3 {
                isDown = false
                registerPushup()
            }
            lastY = y
        }
    }

    private func registerPushup() {
        guard !completed else { return }
        count += 1
        if count >= requiredCount {
            withAnimation(.spring) { completed = true }
            motionManager.stopAccelerometerUpdates()
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                onComplete()
            }
        }
    }
}
