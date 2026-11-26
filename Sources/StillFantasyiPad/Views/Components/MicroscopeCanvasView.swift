import SwiftUI

/// Interactive microscope viewport encapsulating pinch-to-zoom, clamped panning,
/// double-tap reset, invert filter, and fixed eyepiece reticle grid.
public struct MicroscopeCanvasView: View {
    public let imagePath: String
    public let showGrid: Bool
    public let isInverted: Bool
    public let minZoom: Double
    public let maxZoom: Double
    @Binding public var zoomScale: Double

    @State private var panOffset: CGSize = .zero
    @State private var lastPanOffset: CGSize = .zero
    @State private var pinchStartScale: Double? = nil
    @State private var viewportSize: CGSize = .zero

    public init(
        imagePath: String,
        showGrid: Bool,
        isInverted: Bool,
        minZoom: Double = 1.0,
        maxZoom: Double = 4.0,
        zoomScale: Binding<Double>
    ) {
        self.imagePath = imagePath
        self.showGrid = showGrid
        self.isInverted = isInverted
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self._zoomScale = zoomScale
    }

    private func resetTransform() {
        zoomScale = minZoom
        panOffset = .zero
        lastPanOffset = .zero
        pinchStartScale = nil
    }

    private func clampedOffset(_ offset: CGSize, scale: Double) -> CGSize {
        let maxX = viewportSize.width * CGFloat(max(scale - 1, 0)) / 2
        let maxY = viewportSize.height * CGFloat(max(scale - 1, 0)) / 2
        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard zoomScale > minZoom else { return }
                panOffset = clampedOffset(
                    CGSize(
                        width: lastPanOffset.width + value.translation.width,
                        height: lastPanOffset.height + value.translation.height
                    ),
                    scale: zoomScale
                )
            }
            .onEnded { _ in
                lastPanOffset = panOffset
            }
    }

    private var pinchGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let start = pinchStartScale ?? zoomScale
                pinchStartScale = start
                zoomScale = min(max(start * Double(value.magnification), minZoom), maxZoom)
            }
            .onEnded { _ in
                pinchStartScale = nil
            }
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                Group {
                    if isInverted {
                        SpecimenImageView(imagePath, contentMode: .fill)
                            .colorInvert()
                    } else {
                        SpecimenImageView(imagePath, contentMode: .fill)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .scaleEffect(CGFloat(zoomScale))
                .offset(panOffset)
                .animation(.easeOut(duration: 0.12), value: zoomScale)

                if showGrid {
                    reticleOverlay(in: geo.size)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(panGesture)
            .simultaneousGesture(pinchGesture)
            .onTapGesture(count: 2) {
                withAnimation(.easeOut(duration: 0.2)) {
                    resetTransform()
                }
            }
            .onAppear { viewportSize = geo.size }
            .onChange(of: geo.size) { _, newSize in
                viewportSize = newSize
                panOffset = clampedOffset(panOffset, scale: zoomScale)
                lastPanOffset = panOffset
            }
            .onChange(of: zoomScale) { _, newScale in
                if newScale <= minZoom + 0.001 {
                    panOffset = .zero
                    lastPanOffset = .zero
                } else {
                    panOffset = clampedOffset(panOffset, scale: newScale)
                    lastPanOffset = panOffset
                }
            }
            .onChange(of: imagePath) { _, _ in
                resetTransform()
            }
        }
        .clipped()
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private func reticleOverlay(in size: CGSize) -> some View {
        Path { path in
            let w = size.width
            let h = size.height

            path.move(to: CGPoint(x: w / 2, y: 0))
            path.addLine(to: CGPoint(x: w / 2, y: h))
            path.move(to: CGPoint(x: 0, y: h / 2))
            path.addLine(to: CGPoint(x: w, y: h / 2))

            let step: CGFloat = 80
            var x = step
            while x < w {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: h))
                x += step
            }
            var y = step
            while y < h {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: w, y: y))
                y += step
            }
        }
        .stroke(Color.biolumMint.opacity(0.15), lineWidth: 0.8)
        .allowsHitTesting(false)

        Circle()
            .stroke(Color.biolumMint.opacity(0.4), lineWidth: 1.5)
            .frame(width: 140, height: 140)
            .position(x: size.width / 2, y: size.height / 2)
            .allowsHitTesting(false)
    }
}
