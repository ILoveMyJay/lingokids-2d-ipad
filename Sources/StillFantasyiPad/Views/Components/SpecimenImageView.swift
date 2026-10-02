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

public struct SpecimenImageView: View {
    let path: String
    let contentMode: ContentMode

    public init(_ path: String, contentMode: ContentMode = .fill) {
        self.path = path
        self.contentMode = contentMode
    }

    private var cleanKey: String {
        path.hasPrefix("/") ? String(path.dropFirst()) : path
    }

    public var body: some View {
        Group {
            if let platformImg = loadPlatformImage(path: path) {
                #if canImport(UIKit)
                Image(uiImage: platformImg)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #elseif canImport(AppKit)
                Image(nsImage: platformImg)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #endif
            } else if let r2Url = URL(string: "\(R2_ASSET_BASE_URL)/\(cleanKey)") {
                AsyncImage(url: r2Url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    case .failure(_):
                        placeholderView
                    case .empty:
                        ZStack {
                            Color.darkEmeraldSurface
                            ProgressView()
                                .tint(Color.biolumMint)
                        }
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
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
