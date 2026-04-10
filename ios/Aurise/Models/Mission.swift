import SwiftUI

nonisolated enum MissionType: String, CaseIterable, Codable, Sendable, Identifiable {
    case math
    case shakePhone
    case objectHunt
    case photoBed
    case photoSky
    case pushups
    case quiz
    case bibleVerse
    case affirmations
    case readNews

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .math: "Math Problems"
        case .shakePhone: "Shake Phone"
        case .objectHunt: "Object Hunt"
        case .photoBed: "Photo of Bed"
        case .photoSky: "Photo of Sky"
        case .pushups: "Pushups"
        case .quiz: "Knowledge Quiz"
        case .bibleVerse: "Bible Verse"
        case .affirmations: "Affirmations"
        case .readNews: "Read News"
        }
    }

    var shortName: String {
        switch self {
        case .math: "Math"
        case .shakePhone: "Shake"
        case .objectHunt: "Object Hunt"
        case .photoBed: "Photo Bed"
        case .photoSky: "Photo Sky"
        case .pushups: "Pushups"
        case .quiz: "Quiz"
        case .bibleVerse: "Bible"
        case .affirmations: "Affirm"
        case .readNews: "News"
        }
    }

    var icon: String {
        switch self {
        case .math: "function"
        case .shakePhone: "iphone.radiowaves.left.and.right"
        case .objectHunt: "viewfinder"
        case .photoBed: "bed.double.fill"
        case .photoSky: "sun.horizon.fill"
        case .pushups: "figure.strengthtraining.traditional"
        case .quiz: "brain.head.profile"
        case .bibleVerse: "book.fill"
        case .affirmations: "text.quote"
        case .readNews: "newspaper.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .math: "Solve equations to wake your brain up"
        case .shakePhone: "Shake your phone 30 times to dismiss"
        case .objectHunt: "Find and scan a specific object"
        case .photoBed: "Take a photo of your made bed"
        case .photoSky: "Go outside and photograph the sky"
        case .pushups: "Film yourself doing pushups"
        case .quiz: "Answer general knowledge questions"
        case .bibleVerse: "Read and reflect on a daily verse"
        case .affirmations: "Read your morning affirmations aloud"
        case .readNews: "Read a news article to dismiss"
        }
    }

    var wakeEffectDescription: String {
        switch self {
        case .math: "Forces cognitive engagement — your brain can't stay asleep while solving problems."
        case .shakePhone: "Physical motion activates your body and breaks the stillness of sleep."
        case .objectHunt: "Gets you moving through your space with purpose and focus."
        case .photoBed: "Making your bed is the first win of the day — and proves you're up."
        case .photoSky: "Sunlight exposure is the strongest natural wake signal your body responds to."
        case .pushups: "Exercise floods your body with energy and makes going back to bed impossible."
        case .quiz: "Mental engagement that's more interesting than math — keeps your brain active."
        case .bibleVerse: "Start with intention and reflection before the day begins."
        case .affirmations: "Set your mental state for the day with positive reinforcement."
        case .readNews: "Engaging content that transitions your mind into the waking world."
        }
    }

    var isPremium: Bool {
        switch self {
        case .math, .shakePhone: false
        default: true
        }
    }

    var wakeStrength: Int {
        switch self {
        case .pushups: 5
        case .photoSky: 5
        case .objectHunt: 4
        case .shakePhone: 4
        case .photoBed: 4
        case .math: 3
        case .quiz: 3
        case .affirmations: 2
        case .bibleVerse: 2
        case .readNews: 2
        }
    }

    var accentColor: Color {
        switch self {
        case .math: Color(red: 0.30, green: 0.70, blue: 0.95)
        case .shakePhone: Color(red: 0.95, green: 0.55, blue: 0.30)
        case .objectHunt: Color(red: 0.40, green: 0.82, blue: 0.60)
        case .photoBed: Color(red: 0.70, green: 0.55, blue: 0.90)
        case .photoSky: Color(red: 0.95, green: 0.75, blue: 0.30)
        case .pushups: Color(red: 0.95, green: 0.40, blue: 0.40)
        case .quiz: Color(red: 0.50, green: 0.70, blue: 0.95)
        case .bibleVerse: Color(red: 0.80, green: 0.70, blue: 0.55)
        case .affirmations: Color(red: 0.75, green: 0.60, blue: 0.85)
        case .readNews: Color(red: 0.55, green: 0.75, blue: 0.70)
        }
    }

    static var freeMissions: [MissionType] { [.math, .shakePhone] }
    static var premiumMissions: [MissionType] { [.objectHunt, .photoBed, .pushups, .photoSky, .quiz, .bibleVerse, .affirmations, .readNews] }
    static var featuredPremium: [MissionType] { [.objectHunt, .photoBed, .photoSky, .pushups, .quiz] }
    static var secondaryPremium: [MissionType] { [.bibleVerse, .affirmations, .readNews] }
}
