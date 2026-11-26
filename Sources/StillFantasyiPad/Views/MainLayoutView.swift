import SwiftUI

public struct MainLayoutView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            // Narrow windows (portrait / Split View / Slide Over) get an icon-only sidebar.
            let compact = geo.size.width < 900

            ZStack {
                Color.darkEmeraldBg.ignoresSafeArea()

                HStack(spacing: 0) {
                    sidebar(compact: compact)

                    // MARK: - Right Detail Area
                    VStack(spacing: 0) {
                        TopHeaderBar(
                            searchText: $router.searchText,
                            userProfile: appState.userProfile,
                            onOpenProfile: { router.selectTab(.profile) }
                        )

                        Divider().background(Color.darkEmeraldBorder)

                        screenContent
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(alignment: .topLeading) {
                                if !router.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                    SearchResultsView(
                                        query: router.searchText,
                                        isUnlocked: { appState.isUnlocked($0) },
                                        onSelect: { sp in
                                            router.openSpecies(sp.id)
                                        }
                                    )
                                    .padding(.leading, 24)
                                    .padding(.top, 6)
                                }
                            }
                    }
                }

                // MARK: - Global Modals
                if router.showPayModal {
                    PayQRModalView(isPresented: $router.showPayModal)
                        .transition(.opacity)
                }

                if router.showUnlockModal {
                    UnlockCelebrationView(
                        isPresented: $router.showUnlockModal,
                        species: SpeciesDataStore.getSpecies(by: router.unlockedSpeciesId),
                        onNavigateToAnatomy: {
                            router.openAnatomy(for: router.unlockedSpeciesId)
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: router.activeTab)
        .animation(.easeInOut(duration: 0.25), value: router.showPayModal)
        .animation(.easeInOut(duration: 0.25), value: router.showUnlockModal)
        // Narration must not keep playing after the user leaves the page it belongs to.
        .onChange(of: router.activeTab) { _, _ in
            AudioService.shared.stop()
        }
        .onAppear {
            appState.recordVisit(router.selectedSpeciesId)
        }
        .onChange(of: router.selectedSpeciesId) { _, newId in
            appState.recordVisit(newId)
        }
    }

    // MARK: - Screen router

    @ViewBuilder
    private var screenContent: some View {
        switch router.activeTab {
        case .dashboard:
            DashboardView()
        case .species:
            SpeciesDetailView()
        case .anatomy:
            AnatomyStageView()
        case .micro:
            MicroWorldView()
        case .quiz:
            VStack(spacing: 12) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color.biolumMint)
                Text("趣味挑战准备中")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.textLight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.darkEmeraldBg)
        case .codex:
            CodexView()
        case .membership:
            MembershipCenterView()
        case .profile:
            ProfileView()
        }
    }

    // MARK: - Left iPad Sidebar

    private func sidebar(compact: Bool) -> some View {
        let profile = appState.userProfile

        return VStack(alignment: compact ? .center : .leading, spacing: 20) {
            // App Branding
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.biolumMint, Color.biolumEmerald],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.darkEmeraldBg)
                }

                if !compact {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STILL FANTASY")
                            .font(.system(size: 15, weight: .black))
                            .tracking(1)
                            .foregroundColor(Color.textLight)

                        Text("自然探索家 · iPad")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.biolumMint)
                    }
                }
            }
            .padding(.horizontal, compact ? 0 : 16)
            .padding(.top, 16)

            Divider().background(Color.darkEmeraldBorder)

            // Navigation Menu Items (driven by AppTab.allCases)
            VStack(spacing: 6) {
                ForEach(AppTab.allCases) { tab in
                    SidebarNavItem(
                        tab: tab,
                        compact: compact,
                        activeTab: $router.activeTab
                    )
                }
            }
            .padding(.horizontal, compact ? 8 : 12)

            Spacer()

            // Bottom User Status Card
            Button(action: { router.selectTab(.profile) }) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.darkEmeraldSurface)
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.amberGold, lineWidth: 1.5))

                        Text("\(profile.level)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(Color.goldLight)
                    }

                    if !compact {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(profile.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.textLight)

                                if profile.isVip {
                                    Text("VIP")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(Color.darkEmeraldBg)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.goldLight)
                                        .clipShape(Capsule())
                                }
                            }

                            Text(profile.xpProgressText)
                                .font(.system(size: 10))
                                .foregroundColor(Color.textMuted)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.textMuted.opacity(0.6))
                    }
                }
                .padding(compact ? 8 : 12)
                .background(Color.darkEmeraldCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, compact ? 8 : 12)
            .padding(.bottom, 16)
        }
        .frame(width: compact ? 72 : 240)
        .background(Color.darkEmeraldSurface)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color.darkEmeraldBorder),
            alignment: .trailing
        )
    }
}

private struct SidebarNavItem: View {
    let tab: AppTab
    let compact: Bool
    @Binding var activeTab: AppTab

    private var isSelected: Bool {
        activeTab == tab
    }

    var body: some View {
        Button(action: {
            activeTab = tab
        }) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 15))
                    .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textMuted)
                    .frame(width: 22)

                if !compact {
                    Text(tab.title)
                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textLight)

                    Spacer()
                }
            }
            .padding(.horizontal, compact ? 0 : 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [Color.biolumMint, Color.biolumEmerald],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(tab.title)
    }
}
