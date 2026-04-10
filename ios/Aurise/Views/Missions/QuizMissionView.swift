import SwiftUI

struct QuizMissionView: View {
    let onComplete: () -> Void

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex: Int = 0
    @State private var selectedOption: Int? = nil
    @State private var isCorrect: Bool? = nil
    @State private var isLoading: Bool = true
    @State private var completed: Bool = false
    @State private var shakeTrigger: Int = 0

    private let accentColor = MissionType.quiz.accentColor

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if completed {
                completionView
            } else if currentIndex < questions.count {
                questionView(questions[currentIndex])
            }
        }
        .task { await loadQuestions() }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(accentColor)
                .scaleEffect(1.2)
            Text("Generating questions...")
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
            Text("Brain fully activated!")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func questionView(_ question: QuizQuestion) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("QUIZ MISSION")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(2)
                Spacer()
                Text("\(currentIndex + 1) of \(questions.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            GeometryReader { geo in
                let barWidth = geo.size.width * (Double(currentIndex) / Double(questions.count))
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

            VStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28))
                    .foregroundStyle(accentColor)

                Text(question.question)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .offset(x: isCorrect == false ? -6 : 0)
                    .animation(.spring(response: 0.1, dampingFraction: 0.2).repeatCount(3), value: shakeTrigger)
            }

            Spacer()

            VStack(spacing: 10) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        selectOption(index, question: question)
                    } label: {
                        HStack {
                            Text(["A", "B", "C", "D"][index])
                                .font(.body.weight(.bold))
                                .foregroundStyle(optionLabelColor(index))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(optionCircleFill(index)))

                            Text(option)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if selectedOption == index {
                                Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(isCorrect == true ? .green : .red)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(optionFill(index))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(optionBorder(index), lineWidth: 1)
                        )
                    }
                    .disabled(selectedOption != nil)
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 40)
        }
        .sensoryFeedback(.error, trigger: shakeTrigger)
    }

    private func optionLabelColor(_ index: Int) -> Color {
        if selectedOption == index {
            return isCorrect == true ? .green : .red
        }
        return accentColor
    }

    private func optionCircleFill(_ index: Int) -> Color {
        if selectedOption == index {
            return (isCorrect == true ? Color.green : Color.red).opacity(0.15)
        }
        return accentColor.opacity(0.12)
    }

    private func optionFill(_ index: Int) -> Color {
        if selectedOption == index {
            return (isCorrect == true ? Color.green : Color.red).opacity(0.08)
        }
        return .white.opacity(0.06)
    }

    private func optionBorder(_ index: Int) -> Color {
        if selectedOption == index {
            return (isCorrect == true ? Color.green : Color.red).opacity(0.3)
        }
        return .white.opacity(0.08)
    }

    private func selectOption(_ index: Int, question: QuizQuestion) {
        selectedOption = index
        let correct = index == question.correctIndex
        isCorrect = correct

        if !correct {
            shakeTrigger += 1
        }

        Task {
            try? await Task.sleep(for: .seconds(correct ? 0.8 : 1.2))

            if correct {
                if currentIndex + 1 >= questions.count {
                    withAnimation(.spring) { completed = true }
                    try? await Task.sleep(for: .seconds(1.5))
                    onComplete()
                } else {
                    withAnimation(.spring(response: 0.4)) {
                        currentIndex += 1
                        selectedOption = nil
                        isCorrect = nil
                    }
                }
            } else {
                withAnimation {
                    selectedOption = nil
                    isCorrect = nil
                }
            }
        }
    }

    private func loadQuestions() async {
        isLoading = true
        let generated = await AIService.shared.generateQuizQuestions()
        questions = generated
        isLoading = false
    }
}
