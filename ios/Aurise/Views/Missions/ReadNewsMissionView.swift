import SwiftUI

struct ReadNewsMissionView: View {
    let onComplete: () -> Void

    @State private var article: NewsArticleContent? = nil
    @State private var isLoading: Bool = true
    @State private var scrolledToBottom: Bool = false
    @State private var completed: Bool = false
    @State private var readingTime: Int = 0
    @State private var readingTimer: Timer? = nil

    private let accentColor = MissionType.readNews.accentColor
    private let requiredReadTime = 15

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if completed {
                completionView
            } else if let article {
                articleView(article)
            }
        }
        .task { await loadArticle() }
        .onDisappear {
            readingTimer?.invalidate()
            readingTimer = nil
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(accentColor)
                .scaleEffect(1.2)
            Text("Fetching your morning read...")
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
            Text("Stay curious, stay awake.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func articleView(_ article: NewsArticleContent) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("MORNING READ")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(2)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("\(readingTime)s")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            GeometryReader { geo in
                let progress = min(1.0, Double(readingTime) / Double(requiredReadTime))
                let barWidth = geo.size.width * progress
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 4)
                    Capsule().fill(accentColor).frame(width: max(0, barWidth), height: 4)
                        .animation(.spring, value: readingTime)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)
            .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 12)

                    HStack {
                        Text(article.category.uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(accentColor)
                            .tracking(1.2)
                        Spacer()
                        Image(systemName: "newspaper.fill")
                            .foregroundStyle(accentColor)
                    }

                    Text(article.headline)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .lineSpacing(4)

                    Divider().background(.white.opacity(0.1))

                    Text(article.body)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(8)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                            Text("Fun Fact")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.yellow)
                        }
                        Text(article.funFact)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.yellow.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.yellow.opacity(0.1), lineWidth: 1)
                    )

                    if readingTime >= requiredReadTime {
                        Button {
                            finishMission()
                        } label: {
                            Text("I'm awake now")
                                .font(.body.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(accentColor)
                                )
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        Text("Keep reading... \(requiredReadTime - readingTime)s left")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func finishMission() {
        readingTimer?.invalidate()
        readingTimer = nil
        withAnimation(.spring) { completed = true }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            onComplete()
        }
    }

    private func loadArticle() async {
        isLoading = true
        let generated = await AIService.shared.generateNewsArticle()
        article = generated
        isLoading = false
        startReadingTimer()
    }

    private func startReadingTimer() {
        readingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                readingTime += 1
            }
        }
    }
}
