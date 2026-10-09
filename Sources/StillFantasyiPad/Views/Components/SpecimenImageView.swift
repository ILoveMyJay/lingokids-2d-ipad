import SwiftUI
#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

public let R2_ASSET_BASE_URL = "https://pub-b3da7c8f7c904e1cbd9dc49d66964ff6.r2.dev"

// MARK: - Local resource lookup

enum LocalImageLocator {
    /// Looks for a bundled copy of the image. No machine-specific absolute paths:
    /// - app bundle (`Resources/` folder reference, or flattened)
    /// - optional dev override via the STILLFANTASY_RESOURCES_DIR environment variable
    /// - `Resources/` next to the working directory (handy for `swift run` on macOS)
    static func url(for path: String) -> URL? {
        let fm = FileManager.default
        var candidates: [URL] = []

        if let base = Bundle.main.resourceURL {
            candidates.append(base.appendingPathComponent("Resources").appendingPathComponent(path))
            candidates.append(base.appendingPathComponent(path))
        }
        if let dir = ProcessInfo.processInfo.environment["STILLFANTASY_RESOURCES_DIR"], !dir.isEmpty {
            candidates.append(URL(fileURLWithPath: dir).appendingPathComponent(path))
        }
        #if os(macOS)
        candidates.append(URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("Resources").appendingPathComponent(path))
        #endif

        return candidates.first { fm.fileExists(atPath: $0.path) }
    }
}

// MARK: - Cache

public final class ImageCacheService {
    public static let shared = ImageCacheService()

    private let memoryCache = NSCache<NSString, PlatformImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 200 * 1024 * 1024 // 200 MB

        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("SpecimenImageCache", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        self.cacheDirectory = dir
    }

    private func diskFileURL(for key: String) -> URL {
        let safeName = key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "?", with: "_")
        return cacheDirectory.appendingPathComponent(safeName)
    }

    /// Memory-only lookup; cheap enough to call from the main thread.
    public func memoryImage(for key: String) -> PlatformImage? {
        memoryCache.object(forKey: key as NSString)
    }

    /// Memory, then disk. Disk access happens on the calling thread, so call off the main thread.
    public func image(for key: String) -> PlatformImage? {
        if let memImg = memoryImage(for: key) { return memImg }

        let fileURL = diskFileURL(for: key)
        if let data = try? Data(contentsOf: fileURL), let img = Self.decode(data) {
            memoryCache.setObject(img, forKey: key as NSString, cost: data.count)
            return img
        }
        return nil
    }

    public func store(data: Data, for key: String) -> PlatformImage? {
        guard let img = Self.decode(data) else { return nil }   // never cache non-image payloads
        try? data.write(to: diskFileURL(for: key), options: .atomic)
        memoryCache.setObject(img, forKey: key as NSString, cost: data.count)
        return img
    }

    public func remember(_ image: PlatformImage, cost: Int, for key: String) {
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)
    }

    public func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    /// Decodes the image up front (off the main thread) so scrolling doesn't stall on first draw.
    static func decode(_ data: Data) -> PlatformImage? {
        #if canImport(UIKit)
        guard let img = UIImage(data: data) else { return nil }
        return img.preparingForDisplay() ?? img
        #else
        return NSImage(data: data)
        #endif
    }
}

// MARK: - Loader

enum SpecimenImageLoader {
    /// local bundle -> memory/disk cache -> remote (with retry). Returns nil if cancelled or unavailable.
    static func load(key: String) async -> PlatformImage? {
        if let cached = ImageCacheService.shared.memoryImage(for: key) { return cached }

        // Local + disk work happens off the main thread.
        let local: PlatformImage? = await Task.detached(priority: .userInitiated) { () -> PlatformImage? in
            if let url = LocalImageLocator.url(for: key),
               let data = try? Data(contentsOf: url),
               let img = ImageCacheService.decode(data) {
                ImageCacheService.shared.remember(img, cost: data.count, for: key)
                return img
            }
            return ImageCacheService.shared.image(for: key)
        }.value
        if let local { return local }
        if Task.isCancelled { return nil }

        guard let url = URL(string: "\(R2_ASSET_BASE_URL)/\(key)") else { return nil }

        for attempt in 0..<3 {
            if Task.isCancelled { return nil }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                if status == 200 {
                    return await Task.detached(priority: .userInitiated) { () -> PlatformImage? in
                        ImageCacheService.shared.store(data: data, for: key)
                    }.value
                }
                if status == 403 || status == 404 { return nil }   // permanent: don't retry
            } catch {
                if Task.isCancelled { return nil }
            }
            // transient failure: back off 0.5s, 1s, 1.5s
            try? await Task.sleep(nanoseconds: UInt64(attempt + 1) * 500_000_000)
        }
        return nil
    }
}

// MARK: - View

public struct SpecimenImageView: View {
    let path: String
    let contentMode: ContentMode

    @State private var displayImage: PlatformImage? = nil
    @State private var isLoading: Bool = false
    @State private var didFail: Bool = false
    @State private var reloadToken: Int = 0

    public init(_ path: String, contentMode: ContentMode = .fill) {
        self.path = path
        self.contentMode = contentMode
    }

    private var cleanKey: String {
        path.hasPrefix("/") ? String(path.dropFirst()) : path
    }

    public var body: some View {
        Group {
            if let img = displayImage {
                #if canImport(UIKit)
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #elseif canImport(AppKit)
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #endif
            } else if isLoading {
                ZStack {
                    Color.darkEmeraldSurface
                    ProgressView()
                        .tint(Color.biolumMint)
                }
            } else {
                placeholderView
                    .onTapGesture {
                        if didFail { reloadToken += 1 }
                    }
            }
        }
        // .task(id:) cancels the previous load when `path` changes, so a slow old request
        // can never overwrite the image of the newly selected species.
        .task(id: "\(cleanKey)#\(reloadToken)") {
            await load()
        }
    }

    @MainActor
    private func load() async {
        didFail = false
        let key = cleanKey
        if let cached = ImageCacheService.shared.memoryImage(for: key) {
            displayImage = cached
            isLoading = false
            return
        }
        displayImage = nil          // don't keep showing the previous species' image
        isLoading = true
        let img = await SpecimenImageLoader.load(key: key)
        if Task.isCancelled { return }
        isLoading = false
        if let img {
            displayImage = img
        } else {
            didFail = true
        }
    }

    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.darkEmeraldCard, Color.darkEmeraldSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Image(systemName: didFail ? "arrow.clockwise" : "photo.artframe")
                    .font(.system(size: 32))
                    .foregroundColor(Color.biolumMint.opacity(0.4))
                Text(didFail ? "加载失败，轻点重试" : (path.components(separatedBy: "/").last ?? "Specimen"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.textMuted.opacity(0.6))
            }
        }
    }
}
