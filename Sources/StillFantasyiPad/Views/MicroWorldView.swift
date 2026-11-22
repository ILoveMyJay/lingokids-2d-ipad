import SwiftUI

public struct MicroWorldView: View {
    @EnvironmentObject private var router: AppRouter

    @State private var selectedPartIndex: Int = 0
    @State private var selectedClassicIndex: Int = 0
    @State private var zoomScale: Double = 1.0
    @State private var showGrid: Bool = true
    @State private var isInverted: Bool = false
    @State private var mode: MicroMode = .speciesParts
    @ObservedObject private var audioService = AudioService.shared

    public enum MicroMode {
        case speciesParts
        case classic
    }

    private let minZoom: Double = 1.0
    private let maxZoom: Double = 4.0
    private let classicSpecimens = MicroSpecimenDataStore.specimens

    public init() {}

    private var currentSpecies: Species {
        SpeciesDataStore.getSpecies(by: router.selectedSpeciesId)
    }

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

    /// Real optical base magnification of what is on screen (parts are 400x; classic slices carry their own).
    private var baseMagnification: Double {
        if mode == .speciesParts && !currentSpecies.bodyParts.isEmpty { return 400 }
        let item = classicSpecimens[min(selectedClassicIndex, classicSpecimens.count - 1)]
        let digits = item.magnification.filter { $0.isNumber }
        return Double(digits) ?? 400
    }

    private func syncWithSelectedBodyPart() {
        let parts = currentSpecies.bodyParts
        if let partId = router.selectedBodyPartId,
           let idx = parts.firstIndex(where: { $0.id == partId }) {
            selectedPartIndex = idx
            mode = .speciesParts
        } else {
            selectedPartIndex = 0
        }
        zoomScale = minZoom
    }

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header & Controls
            HStack {
                Button(action: { router.selectTab(.anatomy) }) {
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
                    HStack(spacing: 4) {
                        Button(action: { mode = .speciesParts; zoomScale = minZoom }) {
                            Text("当前动物部位")
                                .font(.system(size: 11, weight: mode == .speciesParts ? .bold : .medium))
                                .foregroundColor(mode == .speciesParts ? Color.darkEmeraldBg : Color.textMuted)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(mode == .speciesParts ? Color.biolumMint : Color.clear)
                                .clipShape(Capsule())
                        }

                        Button(action: { mode = .classic; zoomScale = minZoom }) {
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

                    Button(action: { showGrid.toggle() }) {
                        Image(systemName: showGrid ? "grid.circle.fill" : "grid.circle")
                            .font(.system(size: 16))
                            .foregroundColor(showGrid ? Color.biolumMint : Color.textMuted)
                    }
                    .accessibilityLabel(showGrid ? "隐藏标尺网格" : "显示标尺网格")

                    Button(action: { isInverted.toggle() }) {
                        Image(systemName: isInverted ? "circle.righthalf.filled.inverse" : "circle.righthalf.filled")
                            .font(.system(size: 16))
                            .foregroundColor(isInverted ? Color.amberGold : Color.textMuted)
                    }
                    .accessibilityLabel(isInverted ? "关闭反色滤镜" : "开启反色滤镜")

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
                    .accessibilityLabel("语音朗读切片解说")
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.darkEmeraldBg)

            Divider().background(Color.darkEmeraldBorder)

            // MARK: - Center Viewport with Extracted MicroscopeCanvasView
            ZStack(alignment: .bottom) {
                MicroscopeCanvasView(
                    imagePath: activeImage,
                    showGrid: showGrid,
                    isInverted: isInverted,
                    minZoom: minZoom,
                    maxZoom: maxZoom,
                    zoomScale: $zoomScale
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

            // MARK: - Bottom Specimen Carousel & Details
            VStack(alignment: .leading, spacing: 10) {
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

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if mode == .speciesParts {
                            ForEach(0..<currentSpecies.bodyParts.count, id: \.self) { idx in
                                let part = currentSpecies.bodyParts[idx]
                                specimenCard(
                                    image: part.macroImage,
                                    title: part.nameZh,
                                    subtitle: "400× 显微切片",
                                    isSelected: selectedPartIndex == idx
                                ) {
                                    withAnimation(.spring()) {
                                        selectedPartIndex = idx
                                        router.selectedBodyPartId = part.id
                                        zoomScale = minZoom
                                    }
                                }
                            }
                        } else {
                            ForEach(0..<classicSpecimens.count, id: \.self) { idx in
                                let item = classicSpecimens[idx]
                                specimenCard(
                                    image: item.image,
                                    title: item.titleZh,
                                    subtitle: item.magnification,
                                    isSelected: selectedClassicIndex == idx
                                ) {
                                    withAnimation(.spring()) {
                                        selectedClassicIndex = idx
                                        zoomScale = minZoom
                                    }
                                }
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
        .onChange(of: router.selectedBodyPartId) { _, _ in
            syncWithSelectedBodyPart()
        }
        .onChange(of: activeImage) { _, _ in
            audioService.stop()
        }
        .onChange(of: router.selectedSpeciesId) { _, _ in
            syncWithSelectedBodyPart()
        }
    }

    private func specimenCard(
        image: String,
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                SpecimenImageView(image)
                    .frame(width: 48, height: 48)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isSelected ? Color.textLight : Color.textMuted)
                    Text(subtitle)
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
