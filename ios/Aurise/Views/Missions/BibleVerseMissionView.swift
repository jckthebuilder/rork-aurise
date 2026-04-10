import SwiftUI

struct BibleVerseMissionView: View {
    let onComplete: () -> Void

    @State private var verse: BibleVerseContent? = nil
    @State private var isLoading: Bool = true
    @State private var typedWord: String = ""
    @State private var keywordRevealed: Bool = false
    @State private var completed: Bool = false
    @State private var showReflection: Bool = false

    private let accentColor = MissionType.bibleVerse.accentColor

    private var keyword: String {
        guard let verse else { return "" }
        let words = verse.text.components(separatedBy: " ").filter { $0.count > 4 }
        return (words.randomElement() ?? "faith")
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased()
    }

    @State private var cachedKeyword: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                loadingView
            } else if completed {
                completionView
            } else if let verse {
                verseView(verse)
            }
        }
        .task { await loadVerse() }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(accentColor)
                .scaleEffect(1.2)
            Text("Finding today's verse...")
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
            Text("Start your day with purpose.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func verseView(_ verse: BibleVerseContent) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("BIBLE VERSE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(2)
                Spacer()
                Image(systemName: "book.fill")
                    .foregroundStyle(accentColor)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 20)

                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(accentColor)

                    Text(verse.reference)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accentColor)
                        .tracking(1.5)

                    Text("\u{201C}" + verse.text + "\u{201D}")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 20)

                    if showReflection {
                        VStack(spacing: 12) {
                            Divider().background(.white.opacity(0.1))

                            Text("REFLECT")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white.opacity(0.4))
                                .tracking(1.5)

                            Text(verse.reflection)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    if !keywordRevealed {
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                showReflection = true
                                keywordRevealed = true
                            }
                        } label: {
                            Text("I've read the verse")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(accentColor.opacity(0.3))
                                )
                        }
                        .padding(.horizontal, 20)
                    }

                    if keywordRevealed {
                        VStack(spacing: 12) {
                            Text("Type the word: \"\(cachedKeyword)\"")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.6))

                            TextField("", text: $typedWord)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.white.opacity(0.06))
                                )
                                .padding(.horizontal, 40)
                                .onChange(of: typedWord) { _, newValue in
                                    if newValue.lowercased().trimmingCharacters(in: .whitespaces) == cachedKeyword {
                                        finishMission()
                                    }
                                }
                        }
                        .transition(.opacity)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
    }

    private func finishMission() {
        withAnimation(.spring) { completed = true }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            onComplete()
        }
    }

    private func loadVerse() async {
        isLoading = true
        let generated = await AIService.shared.generateBibleVerse()
        verse = generated
        let words = generated.text.components(separatedBy: " ").filter { $0.count > 4 }
        cachedKeyword = (words.randomElement() ?? "faith")
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased()
        isLoading = false
    }
}
