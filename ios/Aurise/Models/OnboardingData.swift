import Foundation

nonisolated enum MorningEase: String, CaseIterable, Sendable {
    case yes = "Yes, mostly"
    case sometimes = "Sometimes"
    case notYet = "Not yet"
}

nonisolated enum BedReason: String, CaseIterable, Sendable {
    case snooze = "I hit snooze over and over"
    case fallAsleep = "I turn it off and fall back asleep"
    case scrolling = "I start scrolling on my phone"
    case tooTired = "I feel too tired to get up"
    case stayInBed = "I stay in bed even when I'm awake"
}

nonisolated enum AlarmCount: String, CaseIterable, Sendable {
    case one = "1"
    case twoThree = "2–3"
    case fourFive = "4–5"
    case sixPlus = "6+"
}

nonisolated enum SingleAlarmWorks: String, CaseIterable, Sendable {
    case yes = "Yes"
    case sometimes = "Sometimes"
    case noChance = "No chance"
}

nonisolated enum WakeUpMission: String, CaseIterable, Sendable {
    case math = "Math"
    case photo = "Photo"

    var icon: String {
        switch self {
        case .math: return "function"
        case .photo: return "camera.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .math: return "Solve a few simple math problems to turn the alarm off."
        case .photo: return "Take a photo of a chosen object or place to prove you're out of bed."
        }
    }

    var explanationHeadline: String {
        switch self {
        case .math: return "Math forces your brain to wake up"
        case .photo: return "Photo missions get you out of bed"
        }
    }

    var explanationBody: String {
        switch self {
        case .math: return "Instead of snoozing on autopilot, you'll have to focus and think before the alarm stops."
        case .photo: return "You'll need to physically move and capture the right object before the alarm stops."
        }
    }
}

nonisolated enum PremiumMission: String, CaseIterable, Sendable {
    case steps = "Steps"
    case makeBed = "Make your bed"

    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .makeBed: return "bed.double.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .steps: return "Walk a set number of steps to dismiss."
        case .makeBed: return "Snap a photo of your made bed."
        }
    }
}

nonisolated struct AlarmSound: Identifiable, Sendable {
    let id: String
    let name: String
    let icon: String

    static let defaults: [AlarmSound] = [
        AlarmSound(id: "clear_bell", name: "Clear Bell", icon: "bell.fill"),
        AlarmSound(id: "sharp_tone", name: "Sharp Tone", icon: "waveform.path"),
        AlarmSound(id: "sunrise_pulse", name: "Sunrise Pulse", icon: "sunrise.fill"),
        AlarmSound(id: "digital_alert", name: "Digital Alert", icon: "waveform"),
        AlarmSound(id: "soft_chime", name: "Soft Chime", icon: "wind"),
        AlarmSound(id: "focus_alarm", name: "Focus Alarm", icon: "bolt.fill"),
    ]
}

nonisolated enum AlarmIntensity: String, CaseIterable, Sendable {
    case gentle = "Gentle"
    case standard = "Standard"
    case hardToIgnore = "Hard to ignore"

    var icon: String {
        switch self {
        case .gentle: return "speaker.wave.1.fill"
        case .standard: return "speaker.wave.2.fill"
        case .hardToIgnore: return "speaker.wave.3.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .gentle: return "A calm start to your morning"
        case .standard: return "Reliable and clear"
        case .hardToIgnore: return "Maximum wake-up power"
        }
    }
}

nonisolated enum Weekday: Int, CaseIterable, Sendable {
    case mon = 0, tue, wed, thu, fri, sat, sun

    var shortName: String {
        switch self {
        case .mon: return "M"
        case .tue: return "T"
        case .wed: return "W"
        case .thu: return "T"
        case .fri: return "F"
        case .sat: return "S"
        case .sun: return "S"
        }
    }

    var fullName: String {
        switch self {
        case .mon: return "Mon"
        case .tue: return "Tue"
        case .wed: return "Wed"
        case .thu: return "Thu"
        case .fri: return "Fri"
        case .sat: return "Sat"
        case .sun: return "Sun"
        }
    }

    static let weekdays: Set<Weekday> = [.mon, .tue, .wed, .thu, .fri]
}
