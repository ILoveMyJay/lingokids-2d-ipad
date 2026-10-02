import Foundation
import AVFoundation

public class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = AudioService()

    private var speechSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    @Published public var isPlaying: Bool = false

    override private init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    public func speak(text: String, language: String = "zh-CN") {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        isPlaying = true
        speechSynthesizer.speak(utterance)
    }

    public func playAudioFile(named path: String) {
        stop()
        if let url = Bundle.main.url(forResource: path, withExtension: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }

    public func stop() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
