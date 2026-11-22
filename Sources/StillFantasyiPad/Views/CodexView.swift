import SwiftUI

public struct CodexView: View {
    public enum CodexFilter: String, Equatable {
        case all
        case insects
        case land
        case ocean
        case birds
        case unlocked
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    let onUnlockSpecies: (String) -> Void

    @State private var selectedFilter: CodexFilter = .all

    private let gridColumns = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]

    public init(onUnlockSpecies: @escaping (String) -> Void) {
        self.onUnlockSpecies = onUnlockSpecies
    }

    private var allSpecies: [Species] {
        SpeciesDataStore.sampleSpecies
    }

    private var filteredSpecies: [Species] {
        allSpecies.filter { sp in
            switch selectedFilter {
            case .all:
                return true
            case .unlocked:
                return appState.isUnlocked(sp.id)
            case .insects, .land, .ocean, .birds:
                return sp.categoryId == selectedFilter.rawValue
            }
        }
    }

    private func count(in categoryId: String) -> Int {
        appState.speciesCount(inCategory: categoryId)
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header & Progress
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("物种图鉴")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(Color.textLight)

                        Text("自然学者的全景生物百科 · 收集并记录每一个造物奇迹")
                            .font(.system(size: 13))
                            .foregroundColor(Color.textMuted)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("已收录 \(appState.unlockedCount) / \(appState.totalSpeciesCount) 种")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.textLight)

                            Text(appState.explorationPercentText)
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(Color.biolumMint)
                        }

                        GeometryReader { barGeo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.darkEmeraldBorderSubtle)
                                    .frame(height: 8)

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.biolumMint, Color.biolumLime],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: barGeo.size.width * CGFloat(appState.explorationProgress), height: 8)
                            }
                        }
                        .frame(width: 180, height: 8)
                    }
                    .padding(14)
                    .background(Color.darkEmeraldCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                    )
                }

                // MARK: - Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterPill(title: "全部 (\(appState.totalSpeciesCount))", value: CodexFilter.all, selection: $selectedFilter)
                        FilterPill(title: "昆虫王国 (\(count(in: "insects")))", value: CodexFilter.insects, selection: $selectedFilter)
                        FilterPill(title: "陆地探险 (\(count(in: "land")))", value: CodexFilter.land, selection: $selectedFilter)
                        FilterPill(title: "深海奇境 (\(count(in: "ocean")))", value: CodexFilter.ocean, selection: $selectedFilter)
                        FilterPill(title: "鸟类天地 (\(count(in: "birds")))", value: CodexFilter.birds, selection: $selectedFilter)
                        FilterPill(title: "已解锁 (\(appState.unlockedCount))", value: CodexFilter.unlocked, selection: $selectedFilter)
                    }
                }

                // MARK: - Species Adaptive Grid
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(filteredSpecies) { sp in
                        if appState.isUnlocked(sp.id) {
                            unlockedCard(for: sp)
                        } else {
                            lockedCard(for: sp)
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color.darkEmeraldBg)
    }

    private func unlockedCard(for sp: Species) -> some View {
        Button(action: {
            router.openSpecies(sp.id)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    SpecimenImageView(sp.coverImage)
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(16)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        Text("已收录")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(Color.darkEmeraldBg)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.biolumMint)
                    .clipShape(Capsule())
                    .padding(8)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(sp.nameZh)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.textLight)

                        Spacer()

                        HStack(spacing: 2) {
                            ForEach(0..<sp.rarity, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(Color.amberGold)
                            }
                        }
                    }

                    Text(sp.scientificName)
                        .font(.system(size: 10, weight: .medium))
                        .italic()
                        .foregroundColor(Color.biolumMint.opacity(0.8))

                    Text(sp.overviewZh)
                        .font(.system(size: 11))
                        .foregroundColor(Color.textMuted)
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

    private func lockedCard(for sp: Species) -> some View {
        Button(action: {
            onUnlockSpecies(sp.id)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Color.darkEmeraldSurface
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16)

                    VStack(spacing: 6) {
                        Image(systemName: "lock.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color.amberGold.opacity(0.8))

                        Text("点击唤醒图鉴")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.amberGold)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(sp.nameZh)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.textLight.opacity(0.5))

                        Spacer()

                        Text("待解锁")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.amberGold)
                    }

                    Text(sp.scientificName)
                        .font(.system(size: 10))
                        .italic()
                        .foregroundColor(Color.textMuted.opacity(0.4))

                    Text("完成生态考察探险任务后收录")
                        .font(.system(size: 11))
                        .foregroundColor(Color.textMuted.opacity(0.4))
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            .padding(12)
            .background(Color.darkEmeraldCard.opacity(0.6))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.darkEmeraldBorderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
