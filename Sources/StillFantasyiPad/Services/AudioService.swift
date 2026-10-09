import Foundation
import AVFoundation

public final class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    public static let shared = AudioService()

    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private var currentUtterance: AVSpeechUtterance?

    @Published public private(set) var isPlaying: Bool = false
    /// Identifies *what* is playing so each button can show its own state
    /// (e.g. the Chinese and English buttons no longer share one flag).
    @Published public private(set) var currentToken: String?

    override private init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    public func isActive(token: String) -> Bool {
        isPlaying && currentToken == token
    }

    public func speak(text: String, language: String = "zh-CN", token: String? = nil) {
        stop()
        activateSession()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        currentUtterance = utterance
        currentToken = token
        isPlaying = true
        speechSynthesizer.speak(utterance)
    }

    public func playAudioFile(named path: String, token: String? = nil) {
        stop()
        guard let url = Self.resolveAudioURL(path) else { return }
        activateSession()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            audioPlayer = player
            currentToken = token
            if player.play() {
                isPlaying = true
            } else {
                audioPlayer = nil
                currentToken = nil
            }
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    public func stop() {
        let wasActive = isPlaying
        // Clear first so the cancel callback of the old utterance is ignored.
        currentUtterance = nil
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentToken = nil
        if wasActive { deactivateSession() }
    }

    // MARK: - Audio session

    private func activateSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        // .playback keeps narration audible even when the iPad's silent switch is on.
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        #endif
    }

    private func deactivateSession() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    private static func resolveAudioURL(_ path: String) -> URL? {
        if let url = Bundle.main.url(forResource: path, withExtension: nil) { return url }
        if let base = Bundle.main.resourceURL {
            let candidate = base.appendingPathComponent("Resources").appendingPathComponent(path)
            if FileManager.default.fileExists(atPath: candidate.path) { return candidate }
        }
        return nil
    }

    // MARK: - Delegates

    private func finishIfCurrent(utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            guard utterance === self.currentUtterance else { return }
            self.currentUtterance = nil
            self.isPlaying = false
            self.currentToken = nil
            self.deactivateSession()
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        finishIfCurrent(utterance: utterance)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        finishIfCurrent(utterance: utterance)
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            guard player === self.audioPlayer else { return }
            self.audioPlayer = nil
            self.isPlaying = false
            self.currentToken = nil
            self.deactivateSession()
        }
    }
}
