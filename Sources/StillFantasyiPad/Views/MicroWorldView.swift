import SwiftUI

public struct MicroWorldView: View {
    @Binding var selectedSpeciesId: String
    @Binding var selectedBodyPartId: String?
    @Binding var activeTab: String

    @State private var selectedPartIndex: Int = 0
    @State private var selectedClassicIndex: Int = 0
    @State private var zoomScale: Double = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var lastPanOffset: CGSize = .zero
    @State private var pinchStartScale: Double? = nil
    @State private var viewportSize: CGSize = .zero
    @State private var showGrid: Bool = true
    @State private var isInverted: Bool = false
    @State private var mode: MicroMode = .speciesParts
    @ObservedObject private var audioService = AudioService.shared

    public enum MicroMode {
        case speciesParts
        case classic
    }

    private var currentSpecies: Species {
        SpeciesDataStore.getSpecies(by: selectedSpeciesId)
    }

    private let classicSpecimens = MicroSpecimenDataStore.specimens

    public init(
        selectedSpeciesId: Binding<String>,
        selectedBodyPartId: Binding<String?>,
        activeTab: Binding<String>
    ) {
        self._selectedSpeciesId = selectedSpeciesId
        self._selectedBodyPartId = selectedBodyPartId
        self._activeTab = activeTab
    }

    // Currently observed image
    private var activeImage: String {
        if mode == .speciesParts && !currentSpecies.bodyParts.isEmpty {
            let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
            return part.macroImage
        } else {
            let item = classicSpecimens[min(selectedClassicIndex, classicSpecimens.count - 1)]
            return item.image
        }
    }

    private var activeTitleZh: String {
        if mode == .speciesParts && !currentSpecies.bodyParts.isEmpty {
            let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
            return "\(currentSpecies.nameZh) · \(part.nameZh)"
        } else {
            return classicSpecimens[min(selectedClassicIndex, classicSpecimens.count - 1)].titleZh
        }
    }

    private var activeSubtitle: String {
        if mode == .speciesParts && !currentSpecies.bodyParts.isEmpty {
            let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
            return "\(part.nameEn) · 400× 显微镜"
        } else {
            let item = classicSpecimens[min(selectedClassicIndex, classicSpecimens.count - 1)]
            return "\(item.categoryZh) · \(item.magnification)"
        }
    }

    private var activeDescription: String {
        if mode == .speciesParts && !currentSpecies.bodyParts.isEmpty {
            let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
            return part.descZh
        } else {
            return classicSpecimens[min(selectedClassicIndex, classicSpecimens.count - 1)].descZh
        }
    }

    private var activeFunFact: String? {
        if mode == .speciesParts && !currentSpecies.bodyParts.isEmpty {
            let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
            return part.funFactZh
        } else {
            return nil
        }
    }

    private let minZoom: Double = 1.0
    private let maxZoom: Double = 4.0

    /// Real optical base magnification of what is on screen (parts are 400x; classic slices carry their own).
    private var baseMagnification: Double {
        if mode == .speciesParts && !currentSpecies.bodyParts.isEmpty { return 400 }
        let item = classicSpecimens[min(selectedClassicIndex, classicSpecimens.count - 1)]
        let digits = item.magnification.filter { $0.isNumber }
        return Double(digits) ?? 400
    }

    private func resetView() {
        zoomScale = 1.0
        panOffset = .zero
        lastPanOffset = .zero
        pinchStartScale = nil
    }

    /// Keeps the image from being dragged past its own edges (no black borders).
    private func clampedOffset(_ offset: CGSize, scale: Double) -> CGSize {
        let maxX = viewportSize.width * CGFloat(scale - 1) / 2
        let maxY = viewportSize.height * CGFloat(scale - 1) / 2
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
                    CGSize(width: lastPanOffset.width + value.translation.width,
                           height: lastPanOffset.height + value.translation.height),
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

    private func syncWithSelectedBodyPart() {
        let parts = currentSpecies.bodyParts
        if let partId = selectedBodyPartId,
           let idx = parts.firstIndex(where: { $0.id == partId }) {
            selectedPartIndex = idx
            mode = .speciesParts
        } else {
            selectedPartIndex = 0
        }
        resetView()
    }

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header & Controls
            HStack {
                Button(action: { activeTab = "anatomy" }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))
                        Text("返回「\(currentSpecies.nameZh)」解剖台")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(Color.biolumMint)
                }

                Spacer()

                VStack(spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "scope")
                            .foregroundColor(Color.biolumMint)
                        Text(activeTitleZh)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.textLight)
                    }

                    Text(activeSubtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color.biolumMint.opacity(0.8))
                }

                Spacer()

                // Tool toggles & Mode Switch
                HStack(spacing: 12) {
                    // Mode Switch Pills
                    HStack(spacing: 4) {
                        Button(action: { mode = .speciesParts; resetView() }) {
                            Text("当前动物部位")
                                .font(.system(size: 11, weight: mode == .speciesParts ? .bold : .medium))
                                .foregroundColor(mode == .speciesParts ? Color.darkEmeraldBg : Color.textMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(mode == .speciesParts ? Color.biolumMint : Color.clear)
                                .clipShape(Capsule())
                        }

                        Button(action: { mode = .classic; resetView() }) {
                            Text("通用切片")
                                .font(.system(size: 11, weight: mode == .classic ? .bold : .medium))
                                .foregroundColor(mode == .classic ? Color.darkEmeraldBg : Color.textMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(mode == .classic ? Color.biolumMint : Color.clear)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(2)
                    .background(Color.darkEmeraldCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.darkEmeraldBorder, lineWidth: 1))

                    // Grid Toggle
                    Button(action: { showGrid.toggle() }) {
                        Image(systemName: showGrid ? "grid.circle.fill" : "grid.circle")
                            .font(.system(size: 16))
                            .foregroundColor(showGrid ? Color.biolumMint : Color.textMuted)
                    }

                    // Invert Toggle
                    Button(action: { isInverted.toggle() }) {
                        Image(systemName: isInverted ? "circle.righthalf.filled.inverse" : "circle.righthalf.filled")
                            .font(.system(size: 16))
                            .foregroundColor(isInverted ? Color.amberGold : Color.textMuted)
                    }

                    // Audio
                    Button(action: {
                        let token = "micro-\(activeTitleZh)"
                        if audioService.isActive(token: token) {
                            audioService.stop()
                        } else {
                            audioService.speak(text: "\(activeTitleZh)。\(activeDescription) \(activeFunFact ?? "")", token: token)
                        }
                    }) {
                        Image(systemName: audioService.isActive(token: "micro-\(activeTitleZh)") ? "waveform" : "speaker.wave.2")
                            .font(.system(size: 16))
                            .foregroundColor(Color.biolumMint)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.darkEmeraldBg)

            Divider().background(Color.darkEmeraldBorder)

            // MARK: - Center Viewport with Zoom & Grid
            ZStack(alignment: .bottom) {
                // Microscope Specimen View (pinch to zoom, drag to pan, double-tap to reset)
                GeometryReader { geo in
                    ZStack {
                        Color.black

                        Group {
                            if isInverted {
                                SpecimenImageView(activeImage, contentMode: .fill)
                                    .colorInvert()
                            } else {
                                SpecimenImageView(activeImage, contentMode: .fill)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .scaleEffect(CGFloat(zoomScale))
                        .offset(panOffset)
                        .animation(.easeOut(duration: 0.12), value: zoomScale)

                        // Reticle & Grid Overlay (fixed to the eyepiece, like a real reticle)
                        if showGrid {
                            Path { path in
                                let w = geo.size.width
                                let h = geo.size.height

                                // Center crosshair
                                path.move(to: CGPoint(x: w / 2, y: 0))
                                path.addLine(to: CGPoint(x: w / 2, y: h))
                                path.move(to: CGPoint(x: 0, y: h / 2))
                                path.addLine(to: CGPoint(x: w, y: h / 2))

                                // Grid lines
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
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .contentShape(Rectangle())
                    .gesture(panGesture)
                    .simultaneousGesture(pinchGesture)
                    .onTapGesture(count: 2) {
                        withAnimation(.easeOut(duration: 0.2)) { resetView() }
                    }
                    .onAppear { viewportSize = geo.size }
                    .onChange(of: geo.size) { newSize in viewportSize = newSize }
                }
                .clipped()
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1.5)
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Magnification Floating Bar
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("当前等效放大倍率")
                            .font(.system(size: 10))
                            .foregroundColor(Color.textMuted)
                        Text(String(format: "%.0f×", baseMagnification * zoomScale))
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(Color.biolumMint)
                    }

                    // Zoom Slider
                    Slider(value: $zoomScale, in: minZoom...maxZoom, step: 0.1)
                        .tint(Color.biolumMint)

                    HStack(spacing: 4) {
                        Image(systemName: "ruler")
                            .font(.system(size: 11))
                            .foregroundColor(Color.amberGold)
                        Text("物镜标尺 100 μm")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.goldLight)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.darkEmeraldBg.opacity(0.9))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )
                .padding(.horizontal, 48)
                .padding(.bottom, 24)
            }

            // MARK: - Bottom Specimen Carousel & Details (Synchronized!)
            VStack(alignment: .leading, spacing: 10) {
                // Info Bar for Current Specimen
                HStack(alignment: .firstTextBaseline) {
                    Text(activeDescription)
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)
                        .lineLimit(1)

                    Spacer()

                    if let ff = activeFunFact {
                        HStack(spacing: 4) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.amberGold)
                            Text(ff)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color.goldLight)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.amberGold.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }

                // Specimen Horizontal Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if mode == .speciesParts {
                            // Synchronized Animal Body Parts
                            ForEach(0..<currentSpecies.bodyParts.count, id: \.self) { idx in
                                let part = currentSpecies.bodyParts[idx]
                                let isSelected = (selectedPartIndex == idx)

                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedPartIndex = idx
                                        selectedBodyPartId = part.id
                                        resetView()
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        SpecimenImageView(part.macroImage)
                                            .frame(width: 48, height: 48)
                                            .cornerRadius(10)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(part.nameZh)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(isSelected ? Color.textLight : Color.textMuted)
                                            Text("400× 显微切片")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(Color.biolumMint)
                                        }

                                        Spacer()
                                    }
                                    .padding(8)
                                    .frame(width: 170)
                                    .background(isSelected ? Color.darkEmeraldCard : Color.darkEmeraldSurface)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isSelected ? Color.biolumMint : Color.darkEmeraldBorder, lineWidth: isSelected ? 1.5 : 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } else {
                            // Classic Generic Specimens
                            ForEach(0..<classicSpecimens.count, id: \.self) { idx in
                                let item = classicSpecimens[idx]
                                let isSelected = (selectedClassicIndex == idx)

                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedClassicIndex = idx
                                        resetView()
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        SpecimenImageView(item.image)
                                            .frame(width: 48, height: 48)
                                            .cornerRadius(10)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.titleZh)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(isSelected ? Color.textLight : Color.textMuted)
                                            Text(item.magnification)
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(Color.biolumMint)
                                        }

                                        Spacer()
                                    }
                                    .padding(8)
                                    .frame(width: 170)
                                    .background(isSelected ? Color.darkEmeraldCard : Color.darkEmeraldSurface)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isSelected ? Color.biolumMint : Color.darkEmeraldBorder, lineWidth: isSelected ? 1.5 : 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.darkEmeraldBg)
        .onAppear {
            syncWithSelectedBodyPart()
        }
        .onChange(of: selectedBodyPartId) { _ in
            syncWithSelectedBodyPart()
        }
        .onChange(of: zoomScale) { newScale in
            if newScale <= minZoom + 0.001 {
                panOffset = .zero
                lastPanOffset = .zero
            } else {
                panOffset = clampedOffset(panOffset, scale: newScale)
                lastPanOffset = panOffset
            }
        }
        .onChange(of: activeImage) { _ in
            audioService.stop()
        }
        .onChange(of: selectedSpeciesId) { _ in
            syncWithSelectedBodyPart()
        }
    }
}
