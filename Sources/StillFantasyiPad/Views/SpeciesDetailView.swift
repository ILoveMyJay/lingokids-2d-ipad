import SwiftUI

public struct SpeciesDetailView: View {
    @Binding var selectedSpeciesId: String
    @Binding var activeTab: String
    @EnvironmentObject private var appState: AppState
    @State private var selectedSubTab: Int = 0
    @ObservedObject private var audioService = AudioService.shared

    public init(selectedSpeciesId: Binding<String>, activeTab: Binding<String>) {
        self._selectedSpeciesId = selectedSpeciesId
        self._activeTab = activeTab
    }

    private var currentSpecies: Species {
        SpeciesDataStore.getSpecies(by: selectedSpeciesId)
    }

    private var zhToken: String { "species-zh-\(selectedSpeciesId)" }
    private var enToken: String { "species-en-\(selectedSpeciesId)" }

    // List of quick-switch animals
    private var quickSwitchSpecies: [Species] {
        SpeciesDataStore.sampleSpecies
    }

    private var bentoGrid: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("\(currentSpecies.nameZh) · 生物学核心特征")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.textLight)
                    Spacer()
                    Text("已收录 \(currentSpecies.bodyParts.count) 个解剖部位")
                        .font(.system(size: 12))
                        .foregroundColor(Color.biolumMint)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    BentoCard(icon: "ruler", title: "体长 / 展翅", value: currentSpecies.length, desc: "生物外形尺度测量")
                    BentoCard(icon: "hourglass", title: "预期寿命", value: currentSpecies.lifespan, desc: "自然生境下的存活周期")
                    BentoCard(icon: "leaf.fill", title: "主要食性", value: currentSpecies.food, desc: "摄食类型与能量来源")
                    BentoCard(icon: "map.fill", title: "原生栖息地", value: currentSpecies.habitat, desc: "自然地理分布与群落")
                    BentoCard(icon: "sparkles", title: "学名归属", value: currentSpecies.scientificName, desc: "国际动植物命名法典分类")
                    BentoCard(icon: "shield.checkerboard", title: "解剖结构", value: "\(currentSpecies.bodyParts.count) 个核心结构", desc: "可在解剖实验室逐一查看各部位")
                    BentoCard(icon: "trophy.fill", title: "稀有度评级", value: "★ \(currentSpecies.rarity) 星级物种", desc: "生态价值与濒危参考指标")
                    BentoCard(icon: "scope", title: "显微模式", value: "支持 400× 显微", desc: "纳米微观纹理与仿生机制")
                }
            }
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Breadcrumbs & Quick Nav
                HStack(spacing: 8) {
                    Button(action: { activeTab = "dashboard" }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                            Text("返回首页")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color.biolumMint)
                    }

                    Text("/")
                        .foregroundColor(Color.textMuted.opacity(0.4))
                        .font(.system(size: 13))

                    Text(currentSpecies.orderZh)
                        .foregroundColor(Color.textMuted)
                        .font(.system(size: 13))

                    Text("/")
                        .foregroundColor(Color.textMuted.opacity(0.4))
                        .font(.system(size: 13))

                    Text(currentSpecies.nameZh)
                        .foregroundColor(Color.textLight)
                        .font(.system(size: 13, weight: .semibold))

                    Spacer()

                    // Favorite Button
                    Button(action: { appState.toggleFavorite(currentSpecies.id) }) {
                        let isFavorite = appState.isFavorite(currentSpecies.id)
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(isFavorite ? Color.red : Color.textMuted)
                            .frame(width: 38, height: 38)
                            .background(Color.darkEmeraldCard)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.darkEmeraldBorder, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // MARK: - Dynamic Species Switcher Carousel (Click any animal to view details!)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color.biolumMint)
                            .font(.system(size: 12))
                        Text("点击切换探索不同物种:")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.textMuted)
                    }
                    .padding(.horizontal, 24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickSwitchSpecies) { sp in
                                let isSelected = (sp.id == selectedSpeciesId)
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedSpeciesId = sp.id
                                        audioService.stop()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        SpecimenImageView(sp.coverImage)
                                            .frame(width: 28, height: 28)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(isSelected ? Color.biolumMint : Color.clear, lineWidth: 1.5))

                                        Text(sp.nameZh)
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                            .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textLight)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
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
                    }
                }

                // MARK: - Hero Specimen Banner (Dynamically binds to currentSpecies)
                ZStack(alignment: .bottomLeading) {
                    SpecimenImageView(currentSpecies.heroImage)
                        .frame(maxWidth: .infinity)
                        .frame(height: 360)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.darkEmeraldBg.opacity(0.1),
                                    Color.darkEmeraldBg.opacity(0.65),
                                    Color.darkEmeraldBg
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.darkEmeraldBg.opacity(0.9),
                                    Color.darkEmeraldBg.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("\(currentSpecies.orderZh) · \(currentSpecies.familyZh)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.biolumMint)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.biolumMint.opacity(0.15))
                                .clipShape(Capsule())

                            HStack(spacing: 2) {
                                ForEach(0..<currentSpecies.rarity, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.amberGold)
                                }
                            }
                        }

                        Text(currentSpecies.nameZh)
                            .font(.system(size: 44, weight: .black))
                            .foregroundColor(Color.textLight)

                        Text("\(currentSpecies.nameEn) · \(currentSpecies.scientificName)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.biolumMint)

                        Text(currentSpecies.overviewZh)
                            .font(.system(size: 13))
                            .foregroundColor(Color.textMuted)
                            .lineLimit(3)
                            .frame(maxWidth: 580, alignment: .leading)

                        // Bilingual Audio Button
                        HStack(spacing: 12) {
                            Button(action: {
                                if audioService.isActive(token: zhToken) {
                                    audioService.stop()
                                } else {
                                    audioService.speak(text: "\(currentSpecies.nameZh)。\(currentSpecies.overviewZh)", token: zhToken)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: audioService.isActive(token: zhToken) ? "waveform" : "speaker.wave.2.fill")
                                        .font(.system(size: 13))
                                    Text(audioService.isActive(token: zhToken) ? "正在朗读解说..." : "中文语音导览")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(Color.darkEmeraldBg)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.biolumMint)
                                .clipShape(Capsule())
                            }

                            Button(action: {
                                if audioService.isActive(token: enToken) {
                                    audioService.stop()
                                } else {
                                    audioService.speak(text: "\(currentSpecies.nameEn). \(currentSpecies.overviewEn)", language: "en-US", token: enToken)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: audioService.isActive(token: enToken) ? "waveform" : "globe")
                                        .font(.system(size: 13))
                                    Text(audioService.isActive(token: enToken) ? "Playing..." : "English Audio")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(Color.textLight)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.darkEmeraldCard)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.darkEmeraldBorder, lineWidth: 1))
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(28)
                }
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // MARK: - Sub Tab Bar
                HStack(spacing: 12) {
                    let tabs = ["核心特征概览", "生活习性与生态", "生命周期与演变", "400× 微观视界"]
                    ForEach(0..<tabs.count, id: \.self) { idx in
                        Button(action: {
                            if idx == 3 {
                                activeTab = "micro"
                            } else {
                                selectedSubTab = idx
                            }
                        }) {
                            Text(tabs[idx])
                                .font(.system(size: 13, weight: selectedSubTab == idx ? .bold : .medium))
                                .foregroundColor(selectedSubTab == idx ? Color.darkEmeraldBg : Color.textMuted)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedSubTab == idx ? Color.biolumMint : Color.darkEmeraldCard)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(selectedSubTab == idx ? Color.clear : Color.darkEmeraldBorder, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)

                // MARK: - Sub-tab content
                Group {
                    switch selectedSubTab {
                    case 1:
                        SubInfoPanel(
                            title: "\(currentSpecies.nameZh) · 生活习性与生态",
                            cards: [
                                ("leaf.fill", "主要食性", currentSpecies.food, "摄食类型与能量来源"),
                                ("map.fill", "原生栖息地", currentSpecies.habitat, "自然地理分布与群落")
                            ],
                            summary: currentSpecies.overviewZh
                        )
                    case 2:
                        SubInfoPanel(
                            title: "\(currentSpecies.nameZh) · 生命周期与体型",
                            cards: [
                                ("hourglass", "预期寿命", currentSpecies.lifespan, "自然生境下的存活周期"),
                                ("ruler", "体长 / 展翅", currentSpecies.length, "生物外形尺度测量")
                            ],
                            summary: currentSpecies.overviewEn
                        )
                    default:
                        bentoGrid
                    }
                }
                .padding(.horizontal, 24)

                // MARK: - Action Buttons (Navigate to Anatomy or Micro for THIS species)
                HStack(spacing: 16) {
                    Button(action: { activeTab = "anatomy" }) {
                        HStack(spacing: 8) {
                            Image(systemName: "viewfinder")
                                .font(.system(size: 15, weight: .bold))
                            Text("进入「\(currentSpecies.nameZh)」3D 标本解剖实验室")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color.darkEmeraldBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.biolumMint, Color.biolumEmerald],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }

                    Button(action: { activeTab = "micro" }) {
                        HStack(spacing: 8) {
                            Image(systemName: "scope")
                                .font(.system(size: 15, weight: .bold))
                            Text("观察 400× 纳米显微视界")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color.textLight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.darkEmeraldCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.biolumMint.opacity(0.4), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onChange(of: selectedSpeciesId) { _ in
            selectedSubTab = 0
        }
    }
}

private struct BentoCard: View {
    let icon: String
    let title: String
    let value: String
    let desc: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.biolumMint)
                    .font(.system(size: 14))
                Spacer()
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(Color.textMuted)
            }

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.textLight)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(desc)
                .font(.system(size: 10))
                .foregroundColor(Color.textMuted.opacity(0.8))
                .lineLimit(2)
        }
        .padding(14)
        .background(Color.darkEmeraldCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
        )
    }
}

private struct SubInfoPanel: View {
    let title: String
    let cards: [(icon: String, title: String, value: String, desc: String)]
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.textLight)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(0..<cards.count, id: \.self) { idx in
                    BentoCard(icon: cards[idx].icon, title: cards[idx].title, value: cards[idx].value, desc: cards[idx].desc)
                }
            }

            Text(summary)
                .font(.system(size: 13))
                .foregroundColor(Color.textMuted)
                .lineSpacing(5)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.darkEmeraldCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )
        }
    }
}
