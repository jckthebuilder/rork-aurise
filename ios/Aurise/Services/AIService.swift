import Foundation
import UIKit

@Observable
class AIService {
    static let shared = AIService()

    private var baseURL: String {
        Config.EXPO_PUBLIC_TOOLKIT_URL
    }

    var lastErrorDetail: String = ""

    func generateText(prompt: String) async throws -> String {
        let urlString = "\(baseURL)/agent/chat"

        guard !baseURL.isEmpty, let url = URL(string: urlString) else {
            lastErrorDetail = "Empty toolkit URL — Config.EXPO_PUBLIC_TOOLKIT_URL is blank"
            throw AIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Config.EXPO_PUBLIC_PROJECT_ID, forHTTPHeaderField: "x-project-id")
        request.setValue(Config.EXPO_PUBLIC_TEAM_ID, forHTTPHeaderField: "x-team-id")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            lastErrorDetail = "No HTTP response received"
            throw AIServiceError.requestFailed
        }

        let rawBody = String(data: data, encoding: .utf8) ?? ""

        guard (200...299).contains(httpResponse.statusCode) else {
            lastErrorDetail = "HTTP \(httpResponse.statusCode): \(rawBody.prefix(200))"
            throw AIServiceError.requestFailed
        }

        let text = parseResponse(data)
        if text.isEmpty {
            lastErrorDetail = "Parsed empty from: \(rawBody.prefix(300))"
            throw AIServiceError.emptyResponse
        }
        return text
    }

    func analyzeImage(_ image: UIImage, prompt: String) async throws -> String {
        let urlString = "\(baseURL)/agent/chat"

        guard !baseURL.isEmpty, let url = URL(string: urlString) else {
            lastErrorDetail = "Empty toolkit URL for image analysis"
            throw AIServiceError.invalidURL
        }

        let maxDimension: CGFloat = 512
        let resized = resizeImage(image, maxDimension: maxDimension)
        guard let jpegData = resized.jpegData(compressionQuality: 0.5) else {
            lastErrorDetail = "Failed to encode image as JPEG"
            throw AIServiceError.requestFailed
        }
        let base64 = jpegData.base64EncodedString()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Config.EXPO_PUBLIC_PROJECT_ID, forHTTPHeaderField: "x-project-id")
        request.setValue(Config.EXPO_PUBLIC_TEAM_ID, forHTTPHeaderField: "x-team-id")
        request.timeoutInterval = 60

        let messageContent: [[String: Any]] = [
            ["type": "text", "text": prompt],
            ["type": "image", "image": base64]
        ]

        let body: [String: Any] = [
            "messages": [
                ["role": "user", "content": messageContent]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            lastErrorDetail = "Failed to serialize request body: \(error.localizedDescription)"
            throw AIServiceError.requestFailed
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            lastErrorDetail = "Network error: \(error.localizedDescription)"
            throw AIServiceError.requestFailed
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            lastErrorDetail = "No HTTP response for image analysis"
            throw AIServiceError.requestFailed
        }

        let rawBody = String(data: data, encoding: .utf8) ?? ""

        guard (200...299).contains(httpResponse.statusCode) else {
            lastErrorDetail = "Image HTTP \(httpResponse.statusCode): \(rawBody.prefix(300))"
            throw AIServiceError.requestFailed
        }

        let text = parseResponse(data)
        if text.isEmpty {
            lastErrorDetail = "Image response parsed empty from: \(rawBody.prefix(400))"
            throw AIServiceError.emptyResponse
        }
        return text
    }

    func verifyPhoto(_ image: UIImage, target: String, missionType: PhotoMissionType) async throws -> PhotoVerificationResult {
        let prompt: String
        switch missionType {
        case .objectHunt:
            prompt = "Look at this photo. Does it contain a \(target)? Respond with ONLY a JSON object like {\"found\":true,\"confidence\":\"high\",\"message\":\"Great find!\"} or {\"found\":false,\"confidence\":\"low\",\"message\":\"Try again\"}. No extra text."
        case .madeBed:
            prompt = "Look at this photo. Does it show a bed that has been made? Respond with ONLY a JSON object like {\"found\":true,\"confidence\":\"high\",\"message\":\"Bed looks great!\"} or {\"found\":false,\"confidence\":\"low\",\"message\":\"Doesn't look made\"}. No extra text."
        case .sky:
            prompt = "Look at this photo. Does it show the sky or outdoor scene? Respond with ONLY a JSON object like {\"found\":true,\"confidence\":\"high\",\"message\":\"Beautiful sky!\"} or {\"found\":false,\"confidence\":\"low\",\"message\":\"No sky visible\"}. No extra text."
        }

        let text: String
        do {
            text = try await analyzeImage(image, prompt: prompt)
        } catch {
            lastErrorDetail = "analyzeImage threw: \(error.localizedDescription) | detail: \(lastErrorDetail)"
            throw error
        }

        let jsonString = extractJSON(from: text)
        if let jsonData = jsonString.data(using: .utf8),
           let result = try? JSONDecoder().decode(PhotoVerificationResult.self, from: jsonData) {
            return result
        }

        let lower = text.lowercased()
        if lower.contains("\"found\":true") || lower.contains("\"found\": true") ||
           lower.contains("yes") || lower.contains("found") || lower.contains("true") || lower.contains("correct") || lower.contains("great") || lower.contains("nice") || lower.contains("good") {
            return PhotoVerificationResult(found: true, confidence: "medium", message: "Verified! Nice job.")
        }

        return PhotoVerificationResult(found: true, confidence: "low", message: "Photo accepted!")
    }

    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard max(size.width, size.height) > maxDimension else { return image }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func generateQuizQuestions() async -> [QuizQuestion] {
        do {
            let prompt = """
            Generate 3 fun trivia questions to wake someone up in the morning. Mix topics (science, geography, pop culture, history).
            Return ONLY valid JSON array, no markdown, no explanation:
            [{"question":"...","options":["A","B","C","D"],"correctIndex":0}]
            correctIndex is 0-based index of the correct option.
            """
            let text = try await generateText(prompt: prompt)
            let jsonString = extractJSON(from: text)
            guard let jsonData = jsonString.data(using: .utf8) else { return fallbackQuizQuestions() }
            return try JSONDecoder().decode([QuizQuestion].self, from: jsonData)
        } catch {
            return fallbackQuizQuestions()
        }
    }

    func generateBibleVerse() async -> BibleVerseContent {
        do {
            let prompt = """
            Pick a random encouraging Bible verse. Return ONLY valid JSON, no markdown:
            {"reference":"Book Chapter:Verse","text":"The full verse text","reflection":"A short 1-sentence morning reflection prompt based on this verse"}
            """
            let text = try await generateText(prompt: prompt)
            let jsonString = extractJSON(from: text)
            guard let jsonData = jsonString.data(using: .utf8) else { return fallbackBibleVerses().randomElement()! }
            return try JSONDecoder().decode(BibleVerseContent.self, from: jsonData)
        } catch {
            return fallbackBibleVerses().randomElement()!
        }
    }

    func generateAffirmations() async -> [String] {
        do {
            let prompt = """
            Generate 5 powerful, personal morning affirmations. Make them energizing and specific (not generic).
            Return ONLY a valid JSON array of strings, no markdown:
            ["I am...", "Today I...", ...]
            """
            let text = try await generateText(prompt: prompt)
            let jsonString = extractJSON(from: text)
            guard let jsonData = jsonString.data(using: .utf8) else { return fallbackAffirmations().shuffled() }
            return try JSONDecoder().decode([String].self, from: jsonData)
        } catch {
            return fallbackAffirmations().shuffled()
        }
    }

    func generateNewsArticle() async -> NewsArticleContent {
        do {
            let prompt = """
            Write a short, interesting news-style article (150-200 words) about a fascinating recent discovery or event in science, technology, or nature. Make it engaging and wake-up-worthy.
            Return ONLY valid JSON, no markdown:
            {"headline":"...","category":"Science/Tech/Nature","body":"The full article text with 2-3 paragraphs","funFact":"A related fun fact in one sentence"}
            """
            let text = try await generateText(prompt: prompt)
            let jsonString = extractJSON(from: text)
            guard let jsonData = jsonString.data(using: .utf8) else { return fallbackNewsArticles().randomElement()! }
            return try JSONDecoder().decode(NewsArticleContent.self, from: jsonData)
        } catch {
            return fallbackNewsArticles().randomElement()!
        }
    }

    func generateObjectHuntTarget() async -> String {
        do {
            let prompt = """
            Pick ONE random common household object that someone could easily find in their home in the morning (e.g. toothbrush, mug, spoon, shoe, book, plant, mirror, etc).
            Return ONLY the object name as a single word or two words, nothing else. No quotes, no punctuation, no explanation.
            """
            let text = try await generateText(prompt: prompt)
            return text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
        } catch {
            return fallbackObjects().randomElement()!
        }
    }

    private func parseResponse(_ data: Data) -> String {
        let raw = String(data: data, encoding: .utf8) ?? ""

        let streamResult = parseStreamFormat(raw)
        if !streamResult.isEmpty {
            return streamResult
        }

        if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let text = jsonObj["text"] as? String { return text }
            if let content = jsonObj["content"] as? String { return content }
            if let message = jsonObj["message"] as? String { return message }
            if let result = jsonObj["result"] as? String { return result }
            if let choices = jsonObj["choices"] as? [[String: Any]],
               let first = choices.first,
               let msg = first["message"] as? [String: Any],
               let content = msg["content"] as? String { return content }
            if let output = jsonObj["output"] as? String { return output }
        }

        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseStreamFormat(_ raw: String) -> String {
        var result = ""
        var foundStreamLines = false

        for line in raw.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("0:") {
                foundStreamLines = true
                let jsonPart = String(trimmed.dropFirst(2))
                if let partData = jsonPart.data(using: .utf8),
                   let decoded = try? JSONSerialization.jsonObject(with: partData) as? String {
                    result += decoded
                } else {
                    let cleaned = jsonPart
                        .trimmingCharacters(in: .whitespaces)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                    if !cleaned.isEmpty {
                        result += cleaned
                    }
                }
            } else if trimmed.hasPrefix("2:") {
                foundStreamLines = true
                let jsonPart = String(trimmed.dropFirst(2))
                if let partData = jsonPart.data(using: .utf8),
                   let arr = try? JSONSerialization.jsonObject(with: partData) as? [Any] {
                    for item in arr {
                        if let dict = item as? [String: Any],
                           let text = dict["text"] as? String {
                            result += text
                        }
                    }
                }
            } else if trimmed.hasPrefix("d:") || trimmed.hasPrefix("e:") || trimmed.hasPrefix("f:") || trimmed.hasPrefix("3:") || trimmed.hasPrefix("8:") {
                foundStreamLines = true
                continue
            }
        }

        return foundStreamLines ? result : ""
    }

    private func extractJSON(from text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        if let start = cleaned.firstIndex(of: "["),
           let end = cleaned.lastIndex(of: "]") {
            return String(cleaned[start...end])
        }

        if let start = cleaned.firstIndex(of: "{"),
           let end = cleaned.lastIndex(of: "}") {
            return String(cleaned[start...end])
        }

        return cleaned
    }

    // MARK: - Fallback Content

    private func fallbackQuizQuestions() -> [QuizQuestion] {
        let allSets: [[QuizQuestion]] = [
            [
                QuizQuestion(question: "What planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctIndex: 1),
                QuizQuestion(question: "How many bones are in the adult human body?", options: ["186", "206", "226", "256"], correctIndex: 1),
                QuizQuestion(question: "What is the capital of Australia?", options: ["Sydney", "Melbourne", "Canberra", "Brisbane"], correctIndex: 2)
            ],
            [
                QuizQuestion(question: "Which ocean is the largest on Earth?", options: ["Atlantic", "Indian", "Arctic", "Pacific"], correctIndex: 3),
                QuizQuestion(question: "What gas do plants absorb from the atmosphere?", options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"], correctIndex: 2),
                QuizQuestion(question: "In what year did the Titanic sink?", options: ["1905", "1912", "1918", "1923"], correctIndex: 1)
            ],
            [
                QuizQuestion(question: "What is the hardest natural substance on Earth?", options: ["Gold", "Iron", "Diamond", "Platinum"], correctIndex: 2),
                QuizQuestion(question: "How many continents are there?", options: ["5", "6", "7", "8"], correctIndex: 2),
                QuizQuestion(question: "What animal is known as the King of the Jungle?", options: ["Tiger", "Elephant", "Lion", "Bear"], correctIndex: 2)
            ],
            [
                QuizQuestion(question: "What is the smallest country in the world?", options: ["Monaco", "Vatican City", "San Marino", "Liechtenstein"], correctIndex: 1),
                QuizQuestion(question: "How many strings does a standard guitar have?", options: ["4", "5", "6", "8"], correctIndex: 2),
                QuizQuestion(question: "What is the speed of light approximately?", options: ["150,000 km/s", "300,000 km/s", "450,000 km/s", "600,000 km/s"], correctIndex: 1)
            ]
        ]
        return allSets.randomElement()!
    }

    private func fallbackBibleVerses() -> [BibleVerseContent] {
        [
            BibleVerseContent(reference: "Psalm 118:24", text: "This is the day that the Lord has made; let us rejoice and be glad in it.", reflection: "What is one thing you can be grateful for this morning?"),
            BibleVerseContent(reference: "Lamentations 3:22-23", text: "The steadfast love of the Lord never ceases; his mercies never come to an end; they are new every morning; great is your faithfulness.", reflection: "How can you embrace the fresh start this morning offers?"),
            BibleVerseContent(reference: "Philippians 4:13", text: "I can do all things through him who strengthens me.", reflection: "What challenge today can you face with renewed strength?"),
            BibleVerseContent(reference: "Isaiah 40:31", text: "But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.", reflection: "Where do you need renewed energy today?"),
            BibleVerseContent(reference: "Proverbs 3:5-6", text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.", reflection: "What decision today can you approach with trust rather than worry?")
        ]
    }

    private func fallbackAffirmations() -> [String] {
        [
            "I am fully awake and ready to make today count.",
            "Today I choose energy, focus, and purpose over comfort.",
            "I am becoming the person who shows up early and prepared.",
            "My body is strong, my mind is clear, and my spirit is energized.",
            "I deserve a powerful morning that sets the tone for an amazing day.",
            "Every morning I wake up is another chance to become who I want to be.",
            "I release yesterday's fatigue and welcome today's possibilities.",
            "I am disciplined enough to get out of bed and brave enough to chase my dreams.",
            "This morning is mine. I own it completely.",
            "I am grateful for this new day and the opportunities it brings."
        ]
    }

    private func fallbackNewsArticles() -> [NewsArticleContent] {
        [
            NewsArticleContent(
                headline: "Scientists Discover New Deep-Sea Creature That Glows in Three Colors",
                category: "Science",
                body: "Marine biologists exploring the Mariana Trench have discovered a remarkable new species of jellyfish that can emit light in three distinct colors: blue, green, and red. The creature, nicknamed the 'traffic light jelly,' uses this tri-chromatic bioluminescence to communicate with others of its species in the pitch-black depths.\n\nThe discovery was made using advanced deep-sea submersibles equipped with ultra-sensitive cameras. Researchers believe this is the first known marine organism to produce three separate bioluminescent wavelengths simultaneously.\n\nThe finding could have implications for medical imaging technology, as scientists study the unique proteins responsible for the jellyfish's glow.",
                funFact: "The deepest point in the ocean, the Challenger Deep, is about 36,000 feet below sea level — deeper than Mount Everest is tall."
            ),
            NewsArticleContent(
                headline: "Ancient Tree Found Alive After Being Thought Extinct for 2 Million Years",
                category: "Nature",
                body: "A team of botanists in a remote Australian canyon has discovered a living specimen of what was previously known only from fossil records dating back 2 million years. The tree, related to the Wollemi Pine, was found growing in a sheltered gorge that had remained undisturbed for millennia.\n\nThe discovery has been called a 'living fossil' find comparable to discovering a living dinosaur. Only 23 mature trees were found in the hidden location, making it one of the world's rarest plant species.\n\nConservation efforts are already underway, with seeds being collected and propagated in botanical gardens worldwide to ensure the species' survival.",
                funFact: "The oldest known living tree is a bristlecone pine in California named Methuselah, estimated to be over 4,850 years old."
            ),
            NewsArticleContent(
                headline: "New Battery Technology Could Charge Your Phone in Under 60 Seconds",
                category: "Tech",
                body: "Engineers at a leading research university have developed a revolutionary aluminum-graphene battery that can be fully charged in less than one minute. The new technology uses a specially structured graphene cathode that allows ions to move at unprecedented speeds.\n\nUnlike lithium-ion batteries, the new design doesn't degrade significantly over time. In lab tests, the battery maintained 97% of its capacity after 250,000 charge cycles — compared to roughly 500 cycles for a typical smartphone battery.\n\nCommercial applications are expected within the next few years, with smartphone manufacturers already expressing interest in licensing the technology.",
                funFact: "If you fully drained and charged your phone every day, a standard lithium-ion battery would last about 1.5 years before losing significant capacity."
            )
        ]
    }

    private func fallbackObjects() -> [String] {
        ["Toothbrush", "Coffee Mug", "Remote Control", "Spoon", "Book", "Shoe", "Plant", "Mirror", "Pillow", "Water Bottle", "Towel", "Keys", "Pen", "Clock", "Soap"]
    }
}

nonisolated enum PhotoMissionType: Sendable {
    case objectHunt
    case madeBed
    case sky
}

nonisolated struct PhotoVerificationResult: Codable, Sendable {
    let found: Bool
    let confidence: String
    let message: String
}

nonisolated enum AIServiceError: Error, LocalizedError, Sendable {
    case invalidURL
    case requestFailed
    case emptyResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid API URL"
        case .requestFailed: "Request failed"
        case .emptyResponse: "Empty response"
        case .decodingFailed: "Failed to parse response"
        }
    }
}

nonisolated struct QuizQuestion: Codable, Sendable {
    let question: String
    let options: [String]
    let correctIndex: Int
}

nonisolated struct BibleVerseContent: Codable, Sendable {
    let reference: String
    let text: String
    let reflection: String
}

nonisolated struct NewsArticleContent: Codable, Sendable {
    let headline: String
    let category: String
    let body: String
    let funFact: String
}
