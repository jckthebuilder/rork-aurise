import AVFoundation
import AudioToolbox
import UIKit

@Observable
@MainActor
class SoundService {
    static let shared = SoundService()

    var isPlaying: Bool = false
    var currentSoundId: String?

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var previewTimer: Timer?
    private var vibrationTimer: Timer?
    private var isLooping: Bool = false

    private init() {}

    func previewSound(_ soundId: String, intensity: String = "standard") {
        if isPlaying && currentSoundId == soundId {
            stopSound()
            return
        }

        stopSound()
        currentSoundId = soundId
        isPlaying = true

        playTone(soundId: soundId, intensity: intensity, loop: false)

        previewTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stopSound()
            }
        }
    }

    func playAlarmSound(_ soundId: String, intensity: String) {
        stopSound()
        currentSoundId = soundId
        isPlaying = true
        isLooping = true

        configureAudioSession()
        playTone(soundId: soundId, intensity: intensity, loop: true)
        startVibrationLoop(intensity: intensity)
    }

    func stopSound() {
        previewTimer?.invalidate()
        previewTimer = nil
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        isLooping = false

        playerNode?.stop()
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil

        isPlaying = false
        currentSoundId = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
    }

    private func playTone(soundId: String, intensity: String, loop: Bool) {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let sampleRate: Double = 44100
        let duration: Double = loop ? 3.0 : 2.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let params = toneParameters(for: soundId)
        let volume = volumeForIntensity(intensity)

        for frame in 0..<Int(frameCount) {
            let t = Float(frame) / Float(sampleRate)
            channelData[frame] = generateSample(t: t, duration: Float(duration), params: params, volume: volume)
        }

        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, at: nil, options: loop ? .loops : [])
            audioEngine = engine
            playerNode = player
        } catch {
            stopSound()
        }
    }

    private func generateSample(t: Float, duration: Float, params: ToneParams, volume: Float) -> Float {
        let attackTime: Float = 0.02
        let releaseTime: Float = 0.3
        let sustainEnd = duration - releaseTime

        let envelope: Float
        if t < attackTime {
            envelope = t / attackTime
        } else if t < sustainEnd {
            envelope = 1.0
        } else {
            envelope = max(0, 1.0 - (t - sustainEnd) / releaseTime)
        }

        var sample: Float = 0

        sample += sin(2.0 * .pi * params.frequency * t) * params.primaryAmp

        if params.harmonic2 > 0 {
            sample += sin(2.0 * .pi * params.frequency * 2.0 * t) * params.harmonic2
        }
        if params.harmonic3 > 0 {
            sample += sin(2.0 * .pi * params.frequency * 3.0 * t) * params.harmonic3
        }

        if params.tremoloRate > 0 {
            let tremolo = 1.0 - params.tremoloDepth * (1.0 + sin(2.0 * .pi * params.tremoloRate * t)) / 2.0
            sample *= tremolo
        }

        if params.pulsePattern {
            let pulsePhase = t.truncatingRemainder(dividingBy: 0.8)
            if pulsePhase > 0.4 {
                sample *= max(0, 1.0 - (pulsePhase - 0.4) * 5.0)
            }
        }

        return sample * volume * envelope
    }

    private func startVibrationLoop(intensity: String) {
        let interval: TimeInterval
        switch intensity {
        case "gentle": interval = 2.0
        case "hardToIgnore": interval = 0.8
        default: interval = 1.2
        }

        triggerVibration(intensity: intensity)

        vibrationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isLooping else { return }
                self.triggerVibration(intensity: intensity)
            }
        }
    }

    private func triggerVibration(intensity: String) {
        switch intensity {
        case "gentle":
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case "hardToIgnore":
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        default:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    private func volumeForIntensity(_ intensity: String) -> Float {
        switch intensity {
        case "gentle": return 0.35
        case "standard": return 0.6
        case "hardToIgnore": return 0.85
        default: return 0.6
        }
    }

    private func toneParameters(for soundId: String) -> ToneParams {
        switch soundId {
        case "clear_bell":
            return ToneParams(frequency: 880, primaryAmp: 0.6, harmonic2: 0.25, harmonic3: 0.1, tremoloRate: 0, tremoloDepth: 0, pulsePattern: true)
        case "sharp_tone":
            return ToneParams(frequency: 1100, primaryAmp: 0.7, harmonic2: 0.15, harmonic3: 0.05, tremoloRate: 8, tremoloDepth: 0.3, pulsePattern: false)
        case "sunrise_pulse":
            return ToneParams(frequency: 660, primaryAmp: 0.5, harmonic2: 0.3, harmonic3: 0.15, tremoloRate: 3, tremoloDepth: 0.4, pulsePattern: false)
        case "digital_alert":
            return ToneParams(frequency: 1000, primaryAmp: 0.65, harmonic2: 0.2, harmonic3: 0.1, tremoloRate: 0, tremoloDepth: 0, pulsePattern: true)
        case "soft_chime":
            return ToneParams(frequency: 523, primaryAmp: 0.45, harmonic2: 0.35, harmonic3: 0.2, tremoloRate: 2, tremoloDepth: 0.2, pulsePattern: false)
        case "focus_alarm":
            return ToneParams(frequency: 1200, primaryAmp: 0.7, harmonic2: 0.1, harmonic3: 0.05, tremoloRate: 6, tremoloDepth: 0.5, pulsePattern: true)
        default:
            return ToneParams(frequency: 880, primaryAmp: 0.6, harmonic2: 0.2, harmonic3: 0.1, tremoloRate: 0, tremoloDepth: 0, pulsePattern: true)
        }
    }
}

private struct ToneParams {
    let frequency: Float
    let primaryAmp: Float
    let harmonic2: Float
    let harmonic3: Float
    let tremoloRate: Float
    let tremoloDepth: Float
    let pulsePattern: Bool
}
