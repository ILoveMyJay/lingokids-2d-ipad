import SwiftUI

public struct DashboardView: View {
    @Binding var activeTab: String
    @Binding var selectedSpeciesId: String
    let onOpenPayModal: () -> Void

    @State private var featuredIndex: Int = 0

    // Top featured species for Hero spotlight
    private let featuredList: [Species] = [
        SpeciesDataStore.getSpecies(by: "rhinoceros-beetle"),
        SpeciesDataStore.getSpecies(by: "blue-morpho"),
        SpeciesDataStore.getSpecies(by: "peregrine-falcon"),
        SpeciesDataStore.getSpecies(by: "green-sea-turtle"),
        SpeciesDataStore.getSpecies(by: "giant-panda"),
        SpeciesDataStore.getSpecies(by: "cheetah")
    ]

    private var currentFeatured: Species {
        featuredList[featuredIndex % featuredList.count]
    }

    public init(activeTab: Binding<String>, selectedSpeciesId: Binding<String>, onOpenPayModal: @escaping () -> Void) {
        self._activeTab = activeTab
        self._selectedSpeciesId = selectedSpeciesId
        self.onOpenPayModal = onOpenPayModal
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Hero Featured Card (Dynamic Switcher with arrows)
                ZStack(alignment: .bottomLeading) {
                    // Background Image with gradient
                    SpecimenImageView(currentFeatured.heroImage)
                        .frame(maxWidth: .infinity)
                        .frame(height: 380)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.darkEmeraldBg.opacity(0.1),
                                    Color.darkEmeraldBg.opacity(0.7),
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
                                    Color.darkEmeraldBg.opacity(0.5),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Hero Content
                    HStack(alignment: .bottom, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text("今日推荐 · \(currentFeatured.orderZh)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.biolumMint)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.biolumMint.opacity(0.15))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.biolumMint.opacity(0.4), lineWidth: 1))

                                HStack(spacing: 2) {
                                    ForEach(0..<currentFeatured.rarity, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.amberGold)
                                    }
                                }

                                Spacer()

                                // Prev / Next Switcher Controls
                                HStack(spacing: 6) {
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            featuredIndex = (featuredIndex - 1 + featuredList.count) % featuredList.count
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color.textLight)
                                            .frame(width: 30, height: 30)
                                            .background(Color.darkEmeraldCard)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.darkEmeraldBorder, lineWidth: 1))
                                    }

                                    Button(action: {
                                        withAnimation(.spring()) {
                                            featuredIndex = (featuredIndex + 1) % featuredList.count
                                        }
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color.textLight)
                                            .frame(width: 30, height: 30)
                                            .background(Color.darkEmeraldCard)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.darkEmeraldBorder, lineWidth: 1))
                                    }
                                }
                            }

                            Text(currentFeatured.nameZh)
                                .font(.system(size: 40, weight: .black))
                                .foregroundColor(Color.textLight)

                            Text("\(currentFeatured.nameEn) · \(currentFeatured.scientificName)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.biolumMint.opacity(0.9))

                            Text(currentFeatured.overviewZh)
                                .font(.system(size: 13))
                                .foregroundColor(Color.textMuted)
                                .lineLimit(3)
                                .frame(maxWidth: 520, alignment: .leading)

                            HStack(spacing: 14) {
                                Button(action: {
                                    selectedSpeciesId = currentFeatured.id
                                    activeTab = "species"
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14, weight: .bold))
                                        Text("进入物种档案")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .foregroundColor(Color.darkEmeraldBg)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.biolumMint, Color.biolumEmerald],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                }

                                Button(action: {
                                    selectedSpeciesId = currentFeatured.id
                                    activeTab = "anatomy"
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "viewfinder")
                                            .font(.system(size: 14))
                                        Text("3D 解剖实验室")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(Color.textLight)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                                    .background(Color.darkEmeraldCard.opacity(0.8))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.darkEmeraldBorder, lineWidth: 1))
                                }
                            }
                            .padding(.top, 4)
                        }

                        Spacer()

                        // Progress Ring Card
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(Color.darkEmeraldBorderSubtle, lineWidth: 8)
                                    .frame(width: 84, height: 84)

                                Circle()
                                    .trim(from: 0.0, to: 0.27)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.biolumMint, Color.biolumEmerald],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 84, height: 84)

                                VStack(spacing: 2) {
                                    Text("27%")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(Color.textLight)
                                    Text("探索度")
                                        .font(.system(size: 9))
                                        .foregroundColor(Color.textMuted)
                                }
                            }

                            Text("已解锁 32/120 种生命")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.textLight)

                            Button(action: { activeTab = "codex" }) {
                                Text("查看我的图鉴 →")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color.biolumMint)
                            }
                        }
                        .padding(16)
                        .background(Color.darkEmeraldCard.opacity(0.85))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                        )
                    }
                    .padding(28)
                }
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1.5)
                )

                // MARK: - 🔥 Popular Species Quick-Browse Carousel (Click ANY animal!)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("热门探险物种 · 点击直达详情")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.textLight)
                            Text("轻触任意生物卡片，即刻开启全景生态解析与解剖学实验")
                                .font(.system(size: 12))
                                .foregroundColor(Color.textMuted)
                        }

                        Spacer()

                        Button(action: { activeTab = "codex" }) {
                            Text("查看全部 32+ 物种 →")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.biolumMint)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(SpeciesDataStore.sampleSpecies.prefix(12)) { sp in
                                Button(action: {
                                    selectedSpeciesId = sp.id
                                    activeTab = "species"
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack(alignment: .topTrailing) {
                                            SpecimenImageView(sp.coverImage)
                                                .frame(width: 140, height: 100)
                                                .clipped()
                                                .cornerRadius(14)

                                            HStack(spacing: 2) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 7))
                                                    .foregroundColor(Color.amberGold)
                                                Text("\(sp.rarity)")
                                                    .font(.system(size: 8, weight: .black))
                                                    .foregroundColor(Color.darkEmeraldBg)
                                            }
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.goldLight)
                                            .clipShape(Capsule())
                                            .padding(6)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(sp.nameZh)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color.textLight)
                                            Text(sp.nameEn)
                                                .font(.system(size: 9))
                                                .foregroundColor(Color.biolumMint)
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.darkEmeraldCard)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }

                // MARK: - Ecosystem Categories Section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("四大生态王国")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.textLight)
                            Text("跨越昆虫、陆地、深海与天空的自然造物殿堂")
                                .font(.system(size: 12))
                                .foregroundColor(Color.textMuted)
                        }

                        Spacer()

                        Button(action: { activeTab = "codex" }) {
                            Text("打开物种图鉴")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.biolumMint)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(CategoryDataStore.categories) { cat in
                            Button(action: {
                                if cat.id == "insects" {
                                    selectedSpeciesId = "rhinoceros-beetle"
                                } else if cat.id == "land" {
                                    selectedSpeciesId = "cheetah"
                                } else if cat.id == "ocean" {
                                    selectedSpeciesId = "green-sea-turtle"
                                } else if cat.id == "birds" {
                                    selectedSpeciesId = "peregrine-falcon"
                                }
                                activeTab = "species"
                            }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ZStack(alignment: .topTrailing) {
                                        SpecimenImageView(cat.coverImg)
                                            .frame(height: 120)
                                            .frame(maxWidth: .infinity)
                                            .clipped()
                                            .cornerRadius(16)

                                        Text("\(cat.speciesCount) 物种")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(Color.darkEmeraldBg)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.biolumMint)
                                            .clipShape(Capsule())
                                            .padding(8)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(cat.nameZh)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color.textLight)
                                        Text(cat.nameEn)
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.textMuted)
                                        Text(cat.descZh)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color.textMuted.opacity(0.8))
                                            .lineLimit(2)
                                            .padding(.top, 2)
                                    }
                                }
                                .padding(12)
                                .background(Color.darkEmeraldCard)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                // MARK: - Micro World Teaser Banner
                HStack(spacing: 20) {
                    SpecimenImageView("images/blue-morpho/part-7-compound-eyes.jpg")
                        .frame(width: 140, height: 110)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.biolumMint.opacity(0.3), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("微观视界 · 纳米光学实验室")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.biolumMint)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.biolumMint.opacity(0.12))
                                .clipShape(Capsule())

                            Text("400× 显微镜模式")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.amberGold)
                        }

                        Text("探索昆虫复眼与蝴蝶鳞片的微观光学奇迹")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.textLight)

                        Text("上万个六边形微型单眼构成的超广角动态视觉，感受超越人类眼界的偏振光世界。")
                            .font(.system(size: 12))
                            .foregroundColor(Color.textMuted)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button(action: { activeTab = "micro" }) {
                        HStack(spacing: 6) {
                            Text("进入显微世界")
                                .font(.system(size: 13, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color.darkEmeraldBg)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.biolumMint)
                        .clipShape(Capsule())
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [Color.darkEmeraldCard, Color.darkEmeraldSurface],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.biolumMint.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(24)
        }
    }
}
