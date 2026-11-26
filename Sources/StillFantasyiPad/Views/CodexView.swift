import SwiftUI

public struct CodexView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    private let gridColumns = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]

    public init() {}

    private var allSpecies: [Species] {
        SpeciesDataStore.sampleSpecies
    }

    private var filteredSpecies: [Species] {
        allSpecies.filter { sp in
            switch router.codexFilter {
            case .all:
                return true
            case .unlocked:
                return appState.isUnlocked(sp.id)
            case .insects, .land, .ocean, .birds, .desert:
                return sp.categoryId == router.codexFilter.rawValue
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
                        FilterPill(title: "全部 (\(appState.totalSpeciesCount))", value: CodexFilter.all, selection: $router.codexFilter)
                        FilterPill(title: "昆虫王国 (\(count(in: "insects")))", value: CodexFilter.insects, selection: $router.codexFilter)
                        FilterPill(title: "陆地探险 (\(count(in: "land")))", value: CodexFilter.land, selection: $router.codexFilter)
                        FilterPill(title: "深海奇境 (\(count(in: "ocean")))", value: CodexFilter.ocean, selection: $router.codexFilter)
                        FilterPill(title: "鸟类天地 (\(count(in: "birds")))", value: CodexFilter.birds, selection: $router.codexFilter)
                        FilterPill(title: "沙漠秘境 (\(count(in: "desert")))", value: CodexFilter.desert, selection: $router.codexFilter)
                        FilterPill(title: "已解锁 (\(appState.unlockedCount))", value: CodexFilter.unlocked, selection: $router.codexFilter)
                    }
                }

                // MARK: - Species Adaptive Grid
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(filteredSpecies) { sp in
                        let unlocked = appState.isUnlocked(sp.id)
                        SpeciesCardView(species: sp, isUnlocked: unlocked) {
                            if unlocked {
                                router.openSpecies(sp.id)
                            } else if appState.unlock(sp.id) {
                                router.presentUnlockCelebration(for: sp.id)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color.darkEmeraldBg)
    }
}
