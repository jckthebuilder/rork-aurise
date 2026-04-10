import SwiftUI
import CoreMotion

struct MissionExecutionView: View {
    let missionType: MissionType
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        switch missionType {
        case .math:
            MathMissionView(onComplete: onComplete)
        case .shakePhone:
            ShakeMissionView(onComplete: onComplete)
        case .objectHunt:
            ObjectHuntMissionView(onComplete: onComplete)
        case .photoBed:
            PhotoBedMissionView(onComplete: onComplete)
        case .photoSky:
            PhotoSkyMissionView(onComplete: onComplete)
        case .pushups:
            PushupsMissionView(onComplete: onComplete)
        case .quiz:
            QuizMissionView(onComplete: onComplete)
        case .bibleVerse:
            BibleVerseMissionView(onComplete: onComplete)
        case .affirmations:
            AffirmationsMissionView(onComplete: onComplete)
        case .readNews:
            ReadNewsMissionView(onComplete: onComplete)
        }
    }
}

struct MathMissionView: View {
    let onComplete: () -> Void
    @State private var currentProblem: Int = 0
    @State private var answer: String = ""
    @State private var num1: Int = 0
    @State private var num2: Int = 0
    @State private var operation: String = "+"
    @State private var correctAnswer: Int = 0
    @State private var isWrong: Bool = false
    @State private var shakeTrigger: Int = 0
    @State private var completed: Bool = false
    @State private var correctFlash: Bool = false

    private let totalProblems = 3

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("MATH MISSION")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(2)
                    Spacer()
                    Text("\(currentProblem + 1) of \(totalProblems)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                GeometryReader { geo in
                    let barWidth = geo.size.width * (Double(currentProblem) / Double(totalProblems))
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.1))
                            .frame(height: 4)
                        Capsule()
                            .fill(AuriseTheme.accent)
                            .frame(width: max(0, barWidth), height: 4)
                            .animation(.spring, value: currentProblem)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 24)
                .padding(.top, 12)

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
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 32) {
                        Text("\(num1) \(operation) \(num2)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .offset(x: isWrong ? -8 : 0)
                            .animation(.spring(response: 0.1, dampingFraction: 0.2).repeatCount(3), value: shakeTrigger)

                        Text(answer.isEmpty ? "?" : answer)
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(isWrong ? .red : (correctFlash ? .green : AuriseTheme.accent))
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(isWrong ? Color.red.opacity(0.08) : (correctFlash ? Color.green.opacity(0.08) : .white.opacity(0.06)))
                            )
                            .padding(.horizontal, 60)
                    }

                    Spacer()

                    numpad
                }

                Spacer()
            }
        }
        .onAppear { generateProblem() }
        .sensoryFeedback(.error, trigger: shakeTrigger)
    }

    private var numpad: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        numButton("\(number)") { answer += "\(number)" }
                    }
                }
            }
            HStack(spacing: 12) {
                numButton("C") {
                    answer = ""
                    isWrong = false
                }
                numButton("0") { answer += "0" }
                Button { checkAnswer() } label: {
                    Text("✓")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AuriseTheme.accent.opacity(0.3))
                        )
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: answer)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
    }

    private func numButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.08))
                )
        }
    }

    private func generateProblem() {
        let ops = ["+", "-", "×"]
        operation = ops.randomElement() ?? "+"
        switch operation {
        case "+":
            num1 = Int.random(in: 10...50)
            num2 = Int.random(in: 5...30)
            correctAnswer = num1 + num2
        case "-":
            num1 = Int.random(in: 20...60)
            num2 = Int.random(in: 5...min(num1, 30))
            correctAnswer = num1 - num2
        case "×":
            num1 = Int.random(in: 3...12)
            num2 = Int.random(in: 2...9)
            correctAnswer = num1 * num2
        default:
            num1 = 10; num2 = 5; correctAnswer = 15
        }
        answer = ""
        isWrong = false
        correctFlash = false
    }

    private func checkAnswer() {
        guard let userAnswer = Int(answer) else { return }
        if userAnswer == correctAnswer {
            correctFlash = true
            if currentProblem + 1 >= totalProblems {
                Task {
                    try? await Task.sleep(for: .seconds(0.4))
                    withAnimation(.spring) { completed = true }
                    try? await Task.sleep(for: .seconds(1.5))
                    onComplete()
                }
            } else {
                Task {
                    try? await Task.sleep(for: .seconds(0.3))
                    currentProblem += 1
                    generateProblem()
                }
            }
        } else {
            isWrong = true
            shakeTrigger += 1
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                answer = ""
                isWrong = false
            }
        }
    }
}

struct ShakeMissionView: View {
    let onComplete: () -> Void
    @State private var shakeCount: Int = 0
    @State private var completed: Bool = false
    @State private var motionManager = CMMotionManager()
    @State private var lastShakeTime: Date = .distantPast

    private let requiredShakes = 30

    private var progress: Double {
        min(1.0, Double(shakeCount) / Double(requiredShakes))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                HStack {
                    Text("SHAKE MISSION")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(2)
                    Spacer()
                    Text("\(shakeCount)/\(requiredShakes)")
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
                                        colors: [AuriseTheme.accent, AuriseTheme.accentSoft, AuriseTheme.accent],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.3), value: shakeCount)

                            VStack(spacing: 4) {
                                Text("\(shakeCount)")
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .contentTransition(.numericText())
                                Text("shakes")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }

                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 32))
                            .foregroundStyle(AuriseTheme.accent)
                            .symbolEffect(.variableColor.iterative, isActive: !completed)

                        Text("Shake your phone!")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                #if targetEnvironment(simulator)
                if !completed {
                    Button {
                        for _ in 0..<5 {
                            registerShake()
                        }
                    } label: {
                        Text("Simulate 5 Shakes")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(.white.opacity(0.12))
                            )
                    }
                    .padding(.bottom, 24)
                }
                #endif
            }
            .padding(.top, 20)
        }
        .onAppear { startMotionDetection() }
        .onDisappear { motionManager.stopAccelerometerUpdates() }
        .sensoryFeedback(.impact(weight: .light), trigger: shakeCount)
    }

    private func startMotionDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            guard let data else { return }
            let magnitude = sqrt(
                data.acceleration.x * data.acceleration.x +
                data.acceleration.y * data.acceleration.y +
                data.acceleration.z * data.acceleration.z
            )
            if magnitude > 2.5 {
                let now = Date()
                if now.timeIntervalSince(lastShakeTime) > 0.15 {
                    lastShakeTime = now
                    registerShake()
                }
            }
        }
    }

    private func registerShake() {
        guard !completed else { return }
        shakeCount += 1
        if shakeCount >= requiredShakes {
            withAnimation(.spring) { completed = true }
            motionManager.stopAccelerometerUpdates()
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                onComplete()
            }
        }
    }
}

struct GenericMissionView: View {
    let mission: MissionType
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(mission.accentColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Image(systemName: mission.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(mission.accentColor)
                }

                Text(mission.displayName)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                Text(mission.subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Text("This mission requires a physical device.\nInstall via the Rork App to use.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)

                Spacer()

                Button {
                    onComplete()
                } label: {
                    Text("Complete (Demo)")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(mission.accentColor)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}
