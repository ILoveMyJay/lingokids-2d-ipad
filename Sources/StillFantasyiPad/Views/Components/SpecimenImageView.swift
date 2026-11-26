import SwiftUI

// MARK: - Specimen Image View

public struct SpecimenImageView: View {
    let path: String
    let contentMode: ContentMode
    let onImageLoaded: ((CGSize) -> Void)?

    @State private var displayImage: PlatformImage? = nil
    @State private var isLoading: Bool = false
    @State private var didFail: Bool = false
    @State private var reloadToken: Int = 0

    public init(
        _ path: String,
        contentMode: ContentMode = .fill,
        onImageLoaded: ((CGSize) -> Void)? = nil
    ) {
        self.path = path
        self.contentMode = contentMode
        self.onImageLoaded = onImageLoaded
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
            onImageLoaded?(cached.size)
            return
        }
        displayImage = nil          // don't keep showing the previous species' image
        isLoading = true
        let img = await SpecimenImageLoader.load(key: key)
        if Task.isCancelled { return }
        isLoading = false
        if let img {
            displayImage = img
            onImageLoaded?(img.size)
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
