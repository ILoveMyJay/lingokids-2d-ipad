import SwiftUI

public struct AnatomyStageView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var selectedPartIndex: Int = 0
    @State private var stageImageSize: CGSize = .zero
    @ObservedObject private var audioService = AudioService.shared

    public init() {}

    private var currentSpecies: Species {
        SpeciesDataStore.getSpecies(by: router.selectedSpeciesId)
    }

    private var selectedPart: BodyPart? {
        currentSpecies.bodyParts[safe: selectedPartIndex] ?? currentSpecies.bodyParts.first
    }

    private var availableSpeciesWithParts: [Species] {
        SpeciesDataStore.sampleSpecies.filter { !$0.bodyParts.isEmpty }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Nav Bar with Animal Selector
            HStack {
                Button(action: { router.selectTab(.species) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))
                        Text("返回物种详情")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(Color.biolumMint)
                }

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "cube.transparent")
                        .foregroundColor(Color.biolumMint)
                    Text("\(currentSpecies.nameZh) · 3D 标本解剖实验室")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.textLight)
                }

                Spacer()

                if let part = selectedPart {
                    let token = "anatomy-\(part.id)"
                    Button(action: {
                        if audioService.isActive(token: token) {
                            audioService.stop()
                        } else {
                            audioService.play(
                                remotePath: AudioPathBuilder.part(
                                    speciesId: currentSpecies.id,
                                    rawPartId: part.rawId,
                                    field: "desc",
                                    lang: .zh
                                ),
                                fallbackText: "\(part.nameZh)。\(part.descZh) \(part.funFactZh ?? "")",
                                language: .zh,
                                token: token
                            )
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: audioService.isActive(token: token) ? "waveform" : "speaker.wave.2")
                                .font(.system(size: 12))
                            Text(audioService.isActive(token: token) ? "解说中" : "语音讲解")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color.darkEmeraldBg)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.biolumMint)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.darkEmeraldBg)

            // MARK: - Quick Animal Switcher Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Text("切换解剖标本:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.textMuted)

                    ForEach(availableSpeciesWithParts) { sp in
                        let isSelected = (sp.id == router.selectedSpeciesId)
                        Button(action: {
                            withAnimation(.spring()) {
                                router.selectedSpeciesId = sp.id
                                selectedPartIndex = 0
                                router.selectedBodyPartId = sp.bodyParts.first?.id
                                audioService.stop()
                            }
                        }) {
                            HStack(spacing: 6) {
                                SpecimenImageView(sp.coverImage)
                                    .frame(width: 22, height: 22)
                                    .clipShape(Circle())

                                Text(sp.nameZh)
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textLight)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(isSelected ? Color.biolumMint : Color.darkEmeraldCard)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(isSelected ? Color.biolumMint : Color.darkEmeraldBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
            }
            .background(Color.darkEmeraldSurface)

            Divider().background(Color.darkEmeraldBorder)

            // MARK: - Main Content: Canvas on Left, Inspector on Right
            HStack(spacing: 20) {
                // Left Specimen Stage with safe-clamped interactive hotspot pins
                VStack(spacing: 16) {
                    GeometryReader { geo in
                        ZStack {
                            SpecimenImageView(currentSpecies.coverImage, contentMode: .fit) { size in
                                stageImageSize = size
                            }
                            .frame(width: geo.size.width, height: geo.size.height)

                            ForEach(Array(currentSpecies.bodyParts.enumerated()), id: \.element.id) { idx, part in
                                let isSelected = (idx == selectedPartIndex)
                                let pos = Self.hotspotPosition(for: part, in: geo.size, imageSize: stageImageSize)
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedPartIndex = idx
                                        router.selectedBodyPartId = part.id
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(isSelected ? Color.biolumMint.opacity(0.28) : Color.darkEmeraldBg.opacity(0.5))
                                            .frame(width: 44, height: 44)
                                        Circle()
                                            .fill(isSelected ? Color.biolumMint : Color.darkEmeraldCard)
                                            .frame(width: 26, height: 26)
                                            .overlay(
                                                Circle().stroke(isSelected ? Color.white : Color.biolumMint, lineWidth: 1.5)
                                            )
                                        Text("\(part.number)")
                                            .font(.system(size: 11, weight: .black))
                                            .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textLight)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .position(pos)
                                .accessibilityLabel("\(part.nameZh) 解剖热点")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.darkEmeraldSurface)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.darkEmeraldBorder, lineWidth: 1.5)
                    )

                    // Bottom Teaser: Micro World
                    HStack(spacing: 16) {
                        if let part = selectedPart {
                            SpecimenImageView(part.macroImage)
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.biolumMint.opacity(0.4), lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(part.nameZh) · 400× 显微切片")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.textLight)
                                Text("探索\(currentSpecies.nameZh)纳米物理结构与仿生空气动力学")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.textMuted)
                            }
                        }

                        Spacer()

                        Button(action: {
                            router.openMicro(partId: selectedPart?.id)
                        }) {
                            HStack(spacing: 4) {
                                Text("进入超微观视界")
                                    .font(.system(size: 12, weight: .bold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(Color.darkEmeraldBg)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.biolumMint)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(14)
                    .background(Color.darkEmeraldCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)

                // Right Inspector Panel
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("解剖部位解析")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.textLight)
                        Spacer()
                        Text("\(currentSpecies.bodyParts.count) 个部位")
                            .font(.system(size: 11))
                            .foregroundColor(Color.biolumMint)
                    }

                    // Part Selector Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<currentSpecies.bodyParts.count, id: \.self) { idx in
                                let part = currentSpecies.bodyParts[idx]
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedPartIndex = idx
                                        router.selectedBodyPartId = part.id
                                    }
                                }) {
                                    Text(part.nameZh)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(selectedPartIndex == idx ? Color.darkEmeraldBg : Color.textMuted)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedPartIndex == idx ? Color.biolumMint : Color.darkEmeraldCard)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule().stroke(selectedPartIndex == idx ? Color.clear : Color.darkEmeraldBorder, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    if let currentPart = selectedPart {
                        VStack(alignment: .leading, spacing: 14) {
                            SpecimenImageView(currentPart.macroImage)
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(currentPart.nameZh)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color.textLight)
                                    Spacer()
                                    Text(currentPart.nameEn)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color.biolumMint)
                                }

                                Text(currentPart.descZh)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.textMuted)
                                    .lineSpacing(4)
                            }

                            if let funFact = currentPart.funFactZh {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(Color.amberGold)
                                            .font(.system(size: 11))
                                        Text("自然进化冷知识")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color.goldLight)
                                    }

                                    Text(funFact)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.textLight.opacity(0.9))
                                        .lineSpacing(3)
                                }
                                .padding(12)
                                .background(Color.amberGold.opacity(0.12))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.amberGold.opacity(0.3), lineWidth: 1)
                                )
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Color.darkEmeraldCard)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                        )
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "hourglass")
                                .font(.system(size: 32))
                                .foregroundColor(Color.amberGold)
                            Text("标本结构解析中")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.textLight)
                            Text("该物种的高精解剖切片正在生成")
                                .font(.system(size: 11))
                                .foregroundColor(Color.textMuted)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.darkEmeraldCard)
                        .cornerRadius(20)
                    }
                }
                .frame(width: 320)
            }
            .padding(24)
        }
        .background(Color.darkEmeraldBg)
        .onAppear {
            syncActivePart()
        }
        .onChange(of: router.selectedSpeciesId) { _, _ in
            stageImageSize = .zero
            syncActivePart()
        }
        .onChange(of: selectedPartIndex) { _, _ in
            audioService.stop()
            preloadActiveAndNextPartAudio()
        }
        .onChange(of: router.selectedBodyPartId) { _, _ in
            syncActivePart()
        }
    }

    /// Computes the centered aspect-fit drawing rect of an image inside `containerSize`.
    public static func aspectFitRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        guard containerSize.width > 0, containerSize.height > 0 else {
            return .zero
        }
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGRect(origin: .zero, size: containerSize)
        }
        let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(
            x: (containerSize.width - drawSize.width) / 2.0,
            y: (containerSize.height - drawSize.height) / 2.0
        )
        return CGRect(origin: origin, size: drawSize)
    }

    /// Maps 0...100 hotspot coordinates into the actual aspect-fit image rect while
    /// clamping within `edgePadding` inside the stage container so 44pt tap targets stay visible.
    public static func hotspotPosition(
        for part: BodyPart,
        in containerSize: CGSize,
        imageSize: CGSize,
        edgePadding: CGFloat = 24
    ) -> CGPoint {
        let rect = aspectFitRect(imageSize: imageSize, in: containerSize)
        let nx = min(max(part.hotspotX / 100.0, 0.0), 1.0)
        let ny = min(max(part.hotspotY / 100.0, 0.0), 1.0)
        let rawX = rect.minX + rect.width * CGFloat(nx)
        let rawY = rect.minY + rect.height * CGFloat(ny)

        let padX = min(edgePadding, containerSize.width / 2.0)
        let padY = min(edgePadding, containerSize.height / 2.0)
        let clampedX = min(max(rawX, padX), max(containerSize.width - padX, padX))
        let clampedY = min(max(rawY, padY), max(containerSize.height - padY, padY))
        return CGPoint(x: clampedX, y: clampedY)
    }

    private func syncActivePart() {
        if let partId = router.selectedBodyPartId,
           let idx = currentSpecies.bodyParts.firstIndex(where: { $0.id == partId }) {
            selectedPartIndex = idx
        } else {
            selectedPartIndex = 0
            router.selectedBodyPartId = currentSpecies.bodyParts.first?.id
        }
        preloadActiveAndNextPartAudio()
    }

    private func preloadActiveAndNextPartAudio() {
        var paths: [String] = []
        if let current = selectedPart {
            paths.append(AudioPathBuilder.part(speciesId: currentSpecies.id, rawPartId: current.rawId, field: "desc", lang: .zh))
            paths.append(AudioPathBuilder.part(speciesId: currentSpecies.id, rawPartId: current.rawId, field: "desc", lang: .en))
        }
        if let next = currentSpecies.bodyParts[safe: selectedPartIndex + 1] {
            paths.append(AudioPathBuilder.part(speciesId: currentSpecies.id, rawPartId: next.rawId, field: "desc", lang: .zh))
        }
        audioService.preload(remotePaths: paths)
    }
}
