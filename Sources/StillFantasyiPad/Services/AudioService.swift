import Foundation
import AVFoundation

// MARK: - Bilingual Audio Language & Path Builder (aligned with AGENTS.md & web audioPaths.ts)

public enum AudioLanguage: String, CaseIterable {
    case zh
    case en

    /// Fallback system speech locale when offline or pre-recorded MP3 is unavailable.
    /// Per AGENTS.md: English uses British documentary tone (`en-GB`).
    public var speechLocale: String {
        switch self {
        case .zh: return "zh-CN"
        case .en: return "en-GB"
        }
    }
}

public enum AudioPathBuilder {
    public static func speciesName(speciesId: String, lang: AudioLanguage) -> String {
        "audio/\(speciesId)/name_\(lang.rawValue).mp3"
    }

    public static func speciesNickname(speciesId: String, lang: AudioLanguage) -> String {
        "audio/\(speciesId)/nickname_\(lang.rawValue).mp3"
    }

    public static func speciesOverview(speciesId: String, lang: AudioLanguage) -> String {
        "audio/\(speciesId)/overview_\(lang.rawValue).mp3"
    }

    public static func basicInfo(speciesId: String, field: String, lang: AudioLanguage) -> String {
        "audio/\(speciesId)/info_\(field)_\(lang.rawValue).mp3"
    }

    public static func part(
        speciesId: String,
        rawPartId: String,
        field: String = "desc",
        lang: AudioLanguage
    ) -> String {
        "audio/\(speciesId)/parts/part-\(rawPartId)-\(field)_\(lang.rawValue).mp3"
    }

    public static func quiz(
        speciesId: String,
        questionId: String,
        field: String = "prompt",
        lang: AudioLanguage
    ) -> String {
        "audio/\(speciesId)/quiz/quiz-\(questionId)-\(field)_\(lang.rawValue).mp3"
    }

    public static func category(categoryId: String, type: String = "intro") -> String {
        "audio/categories/category-\(categoryId)-\(type).mp3"
    }
}

// MARK: - Disk Audio Cache Store (with LRU Eviction)

public final class AudioCacheStore {
    public static let shared = AudioCacheStore()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxDiskBytes: Int64
    private let diskQueue = DispatchQueue(label: "com.stillfantasy.audiocache.disk")

    public init(
        cacheDirectory: URL? = nil,
        maxDiskBytes: Int64 = 200 * 1024 * 1024
    ) {
        self.maxDiskBytes = maxDiskBytes
        if let cacheDirectory {
            self.cacheDirectory = cacheDirectory
        } else {
            let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            self.cacheDirectory = paths[0].appendingPathComponent("SpecimenAudioCache", isDirectory: true)
        }
        if !fileManager.fileExists(atPath: self.cacheDirectory.path) {
            try? fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        }
    }

    private func diskFileURL(for key: String) -> URL {
        let clean = key.hasPrefix("/") ? String(key.dropFirst()) : key
        let safeName = clean
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "?", with: "_")
        return cacheDirectory.appendingPathComponent(safeName)
    }

    public func cachedFileURL(for key: String) -> URL? {
        let url = diskFileURL(for: key)
        return diskQueue.sync {
            guard fileManager.fileExists(atPath: url.path) else { return nil }
            try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
            return url
        }
    }

    @discardableResult
    public func store(data: Data, for key: String) -> URL? {
        guard !data.isEmpty else { return nil }
        let url = diskFileURL(for: key)
        return diskQueue.sync {
            if !fileManager.fileExists(atPath: cacheDirectory.path) {
                try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            }
            do {
                try data.write(to: url, options: .atomic)
                trimDiskCacheIfNeededLocked()
                return url
            } catch {
                return nil
            }
        }
    }

    public func diskCacheSizeBytes() -> Int64 {
        diskQueue.sync {
            totalDiskBytesLocked()
        }
    }

    public var formattedDiskCacheSize: String {
        ByteCountFormatter.string(fromByteCount: diskCacheSizeBytes(), countStyle: .file)
    }

    public func clearCache() {
        diskQueue.sync {
            try? fileManager.removeItem(at: cacheDirectory)
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    private func cachedEntriesLocked() -> [(url: URL, size: Int64, modified: Date)] {
        let keys: [URLResourceKey] = [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey]
        guard let urls = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return urls.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: Set(keys)),
                  values.isRegularFile == true else {
                return nil
            }
            return (url, Int64(values.fileSize ?? 0), values.contentModificationDate ?? .distantPast)
        }
    }

    private func totalDiskBytesLocked() -> Int64 {
        cachedEntriesLocked().reduce(0) { $0 + $1.size }
    }

    private func trimDiskCacheIfNeededLocked() {
        guard maxDiskBytes > 0 else { return }
        var entries = cachedEntriesLocked()
        var total = entries.reduce(0) { $0 + $1.size }
        guard total > maxDiskBytes else { return }

        let targetBytes = Int64(Double(maxDiskBytes) * 0.8)
        entries.sort { $0.modified < $1.modified }
        for entry in entries {
            guard total > targetBytes else { break }
            if (try? fileManager.removeItem(at: entry.url)) != nil {
                total -= entry.size
            }
        }
    }
}

// MARK: - MainActor Audio Service (R2 Pre-recorded Neural TTS Primary + System Speech Fallback)

@MainActor
public final class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    public static let shared = AudioService()

    private static let preferOfflineKey = "sf.preferOfflineTTS"

    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private var currentUtterance: AVSpeechUtterance?
    private var activePlayTask: Task<Void, Never>?
    private var activeRequestId: UUID?
    private var activePrefetchKeys: Set<String> = []

    @Published public private(set) var isPlaying: Bool = false
    /// Identifies *what* is playing so each button can show its own state
    /// (e.g. the Chinese and English buttons no longer share one flag).
    @Published public private(set) var currentToken: String?
    /// When false (default), plays pre-recorded Edge Neural MP3s from bundle/cache/R2 and falls back to AVSpeechSynthesizer offline.
    @Published public var preferOfflineSystemTTS: Bool {
        didSet {
            UserDefaults.standard.set(preferOfflineSystemTTS, forKey: Self.preferOfflineKey)
        }
    }

    override private init() {
        self.preferOfflineSystemTTS = UserDefaults.standard.bool(forKey: Self.preferOfflineKey)
        super.init()
        speechSynthesizer.delegate = self
    }

    public func isActive(token: String) -> Bool {
        isPlaying && currentToken == token
    }

    /// Plays pre-recorded Neural TTS MP3 from local bundle -> disk cache -> Cloudflare R2,
    /// transparently falling back to `AVSpeechSynthesizer` if offline or the MP3 is unavailable.
    public func play(
        remotePath: String,
        fallbackText: String,
        language: AudioLanguage,
        token: String
    ) {
        stop()

        let cleanKey = remotePath.hasPrefix("/") ? String(remotePath.dropFirst()) : remotePath
        if preferOfflineSystemTTS {
            speak(text: fallbackText, language: language.speechLocale, token: token)
            return
        }

        if let localURL = LocalAssetLocator.url(for: cleanKey) ?? AudioCacheStore.shared.cachedFileURL(for: cleanKey) {
            if startAudioPlayer(url: localURL, token: token) {
                return
            }
        }

        let requestId = UUID()
        activeRequestId = requestId
        currentToken = token
        isPlaying = true

        activePlayTask = Task { [weak self] in
            guard let self else { return }
            let downloadedURL = await Self.fetchAndCacheAudio(for: cleanKey)
            guard !Task.isCancelled, self.activeRequestId == requestId else { return }

            if let downloadedURL, self.startAudioPlayer(url: downloadedURL, token: token) {
                return
            }

            // Fallback when R2 asset is missing (e.g., offline or legacy iPad-only species)
            self.speak(text: fallbackText, language: language.speechLocale, token: token)
        }
    }

    /// Pre-warms R2 MP3 audio files in the background for zero-latency playback on tap.
    public func preload(remotePaths: [String]) {
        guard !preferOfflineSystemTTS else { return }
        for rawPath in remotePaths {
            let key = rawPath.hasPrefix("/") ? String(rawPath.dropFirst()) : rawPath
            guard !key.isEmpty else { continue }
            if LocalAssetLocator.url(for: key) != nil || AudioCacheStore.shared.cachedFileURL(for: key) != nil {
                continue
            }
            guard !activePrefetchKeys.contains(key) else { continue }
            activePrefetchKeys.insert(key)

            Task.detached(priority: .utility) { [weak self] in
                _ = await Self.fetchAndCacheAudio(for: key)
                await MainActor.run {
                    self?.activePrefetchKeys.remove(key)
                }
            }
        }
    }

    public func speak(text: String, language: String = "zh-CN", token: String? = nil) {
        stop()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        activateSession()
        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        currentUtterance = utterance
        currentToken = token
        isPlaying = true
        speechSynthesizer.speak(utterance)
    }

    public func playAudioFile(named path: String, token: String? = nil) {
        stop()
        let clean = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard let url = LocalAssetLocator.url(for: clean) ?? AudioCacheStore.shared.cachedFileURL(for: clean) else {
            return
        }
        _ = startAudioPlayer(url: url, token: token)
    }

    public func stop() {
        let wasActive = isPlaying
        activePlayTask?.cancel()
        activePlayTask = nil
        activeRequestId = nil
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

    // MARK: - Playback Helpers

    private func startAudioPlayer(url: URL, token: String?) -> Bool {
        activateSession()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            audioPlayer = player
            currentToken = token
            if player.play() {
                isPlaying = true
                return true
            }
        } catch {
            // Fall through to cleanup and TTS fallback
        }
        audioPlayer = nil
        currentToken = nil
        isPlaying = false
        deactivateSession()
        return false
    }

    private nonisolated static func fetchAndCacheAudio(for key: String) async -> URL? {
        if let cached = AudioCacheStore.shared.cachedFileURL(for: key) {
            return cached
        }
        guard let remoteURL = R2URLBuilder.url(for: key) else { return nil }
        do {
            let (data, response) = try await URLSession.shared.data(from: remoteURL)
            guard !Task.isCancelled else { return nil }
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard status == 200, !data.isEmpty else { return nil }
            return AudioCacheStore.shared.store(data: data, for: key)
        } catch {
            return nil
        }
    }

    // MARK: - Audio Session

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

    // MARK: - Delegates

    private func finishIfCurrent(utterance: AVSpeechUtterance) {
        guard utterance === currentUtterance else { return }
        currentUtterance = nil
        isPlaying = false
        currentToken = nil
        deactivateSession()
    }

    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.finishIfCurrent(utterance: utterance)
        }
    }

    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.finishIfCurrent(utterance: utterance)
        }
    }

    public nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            guard let self, player === self.audioPlayer else { return }
            self.audioPlayer = nil
            self.isPlaying = false
            self.currentToken = nil
            self.deactivateSession()
        }
    }
}
