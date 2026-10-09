import SwiftUI

public struct AnatomyStageView: View {
    @Binding var selectedSpeciesId: String
    @Binding var selectedBodyPartId: String?
    @Binding var activeTab: String
    @State private var selectedPartIndex: Int = 0
    @ObservedObject private var audioService = AudioService.shared

    public init(selectedSpeciesId: Binding<String>, selectedBodyPartId: Binding<String?>, activeTab: Binding<String>) {
        self._selectedSpeciesId = selectedSpeciesId
        self._selectedBodyPartId = selectedBodyPartId
        self._activeTab = activeTab
    }

    private var currentSpecies: Species {
        SpeciesDataStore.getSpecies(by: selectedSpeciesId)
    }

    private var availableSpeciesWithParts: [Species] {
        SpeciesDataStore.sampleSpecies.filter { !$0.bodyParts.isEmpty }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Nav Bar with Animal Selector
            HStack {
                Button(action: { activeTab = "species" }) {
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

                // Voiceover button
                if !currentSpecies.bodyParts.isEmpty {
                    let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
                    let token = "anatomy-\(part.id)"
                    Button(action: {
                        if audioService.isActive(token: token) {
                            audioService.stop()
                        } else {
                            audioService.speak(text: "\(part.nameZh)。\(part.descZh) \(part.funFactZh ?? "")", token: token)
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
                        let isSelected = (sp.id == selectedSpeciesId)
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedSpeciesId = sp.id
                                selectedPartIndex = 0
                                selectedBodyPartId = sp.bodyParts.first?.id
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
                // Left Specimen Stage
                VStack(spacing: 16) {
                    SpecimenImageView(currentSpecies.coverImage, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.darkEmeraldSurface)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.darkEmeraldBorder, lineWidth: 1.5)
                        )

                    // Bottom Teaser: Micro World
                    HStack(spacing: 16) {
                        if !currentSpecies.bodyParts.isEmpty {
                            let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
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
                            if !currentSpecies.bodyParts.isEmpty {
                                let part = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
                                selectedBodyPartId = part.id
                            }
                            activeTab = "micro"
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
                                        selectedBodyPartId = part.id
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

                    // Detailed Card of Active Part
                    if !currentSpecies.bodyParts.isEmpty {
                        let currentPart = currentSpecies.bodyParts[min(selectedPartIndex, currentSpecies.bodyParts.count - 1)]
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
        .onChange(of: selectedSpeciesId) { _ in
            syncActivePart()
        }
        .onChange(of: selectedPartIndex) { _ in
            audioService.stop()
        }
        .onChange(of: selectedBodyPartId) { _ in
            syncActivePart()
        }
    }

    private func syncActivePart() {
        if let partId = selectedBodyPartId,
           let idx = currentSpecies.bodyParts.firstIndex(where: { $0.id == partId }) {
            selectedPartIndex = idx
        } else {
            selectedPartIndex = 0
            selectedBodyPartId = currentSpecies.bodyParts.first?.id
        }
    }
}
