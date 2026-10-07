import SwiftUI
#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

public func loadPlatformImage(path: String) -> PlatformImage? {
    // 1. Direct filesystem check (lingokids-2d/public or relative)
    let candidatePaths = [
        path,
        "Resources/" + path,
        "../Resources/" + path,
        "../../Resources/" + path,
        "/Users/alan/Documents/AI/ipad/lingokids-2d/public/" + path,
        "/Users/alan/Documents/AI/ipad/StillFantasyiPad/Resources/" + path
    ]
    for p in candidatePaths {
        if FileManager.default.fileExists(atPath: p),
           let data = try? Data(contentsOf: URL(fileURLWithPath: p)) {
            #if canImport(UIKit)
            if let img = UIImage(data: data) { return img }
            #elseif canImport(AppKit)
            if let img = NSImage(data: data) { return img }
            #endif
        }
    }

    // 2. Check Bundle.main
    if let url = Bundle.main.url(forResource: path, withExtension: nil),
       let data = try? Data(contentsOf: url) {
        #if canImport(UIKit)
        if let img = UIImage(data: data) { return img }
        #elseif canImport(AppKit)
        if let img = NSImage(data: data) { return img }
        #endif
    }

    return nil
}

public let R2_ASSET_BASE_URL = "https://pub-b3da7c8f7c904e1cbd9dc49d66964ff6.r2.dev"

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

    public func image(for key: String) -> PlatformImage? {
        // 1. Check memory cache (instant)
        if let memImg = memoryCache.object(forKey: key as NSString) {
            return memImg
        }

        // 2. Check disk cache (persistent offline)
        let fileURL = diskFileURL(for: key)
        if fileManager.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL) {
            #if canImport(UIKit)
            if let img = UIImage(data: data) {
                memoryCache.setObject(img, forKey: key as NSString, cost: data.count)
                return img
            }
            #elseif canImport(AppKit)
            if let img = NSImage(data: data) {
                memoryCache.setObject(img, forKey: key as NSString, cost: data.count)
                return img
            }
            #endif
        }
        return nil
    }

    public func store(data: Data, for key: String) -> PlatformImage? {
        let fileURL = diskFileURL(for: key)
        try? data.write(to: fileURL)

        #if canImport(UIKit)
        if let img = UIImage(data: data) {
            memoryCache.setObject(img, forKey: key as NSString, cost: data.count)
            return img
        }
        #elseif canImport(AppKit)
        if let img = NSImage(data: data) {
            memoryCache.setObject(img, forKey: key as NSString, cost: data.count)
            return img
        }
        #endif
        return nil
    }

    public func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

public struct SpecimenImageView: View {
    let path: String
    let contentMode: ContentMode

    @State private var displayImage: PlatformImage? = nil
    @State private var isLoading: Bool = false

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
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: path) { _ in
            loadImage()
        }
    }

    private func loadImage() {
        // 1. Direct local file check
        if let local = loadPlatformImage(path: path) {
            self.displayImage = local
            return
        }

        // 2. Persistent disk & memory cache check
        if let cached = ImageCacheService.shared.image(for: cleanKey) {
            self.displayImage = cached
            return
        }

        // 3. Cloudflare R2 Remote fetch + auto cache to disk
        guard let url = URL(string: "\(R2_ASSET_BASE_URL)/\(cleanKey)") else {
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                guard let data = data, error == nil,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    return
                }
                if let img = ImageCacheService.shared.store(data: data, for: cleanKey) {
                    self.displayImage = img
                }
            }
        }.resume()
    }

    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.darkEmeraldCard, Color.darkEmeraldSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 32))
                    .foregroundColor(Color.biolumMint.opacity(0.4))
                Text(path.components(separatedBy: "/").last ?? "Specimen")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.textMuted.opacity(0.6))
            }
        }
    }
}
