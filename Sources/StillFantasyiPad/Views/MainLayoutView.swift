import SwiftUI

public struct MainLayoutView: View {
    @EnvironmentObject private var appState: AppState

    @State private var activeTab: String = "dashboard"
    @State private var selectedSpeciesId: String = "blue-morpho"
    @State private var selectedBodyPartId: String? = nil
    @State private var searchText: String = ""

    // Modals
    @State private var showPayModal: Bool = false
    @State private var showUnlockModal: Bool = false
    @State private var unlockedSpeciesId: String = "blue-morpho"

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
                            searchText: $searchText,
                            userProfile: appState.userProfile,
                            onOpenProfile: { activeTab = "profile" }
                        )

                        Divider().background(Color.darkEmeraldBorder)

                        screenContent
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(alignment: .topLeading) {
                                if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                    SearchResultsView(
                                        query: searchText,
                                        isUnlocked: { appState.isUnlocked($0) },
                                        onSelect: { sp in
                                            selectedSpeciesId = sp.id
                                            activeTab = "species"
                                            searchText = ""
                                        }
                                    )
                                    .padding(.leading, 24)
                                    .padding(.top, 6)
                                }
                            }
                    }
                }

                // MARK: - Global Modals
                if showPayModal {
                    PayQRModalView(isPresented: $showPayModal)
                        .transition(.opacity)
                }

                if showUnlockModal {
                    UnlockCelebrationView(
                        isPresented: $showUnlockModal,
                        species: SpeciesDataStore.getSpecies(by: unlockedSpeciesId),
                        onNavigateToAnatomy: {
                            selectedSpeciesId = unlockedSpeciesId
                            activeTab = "anatomy"
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeTab)
        .animation(.easeInOut(duration: 0.25), value: showPayModal)
        .animation(.easeInOut(duration: 0.25), value: showUnlockModal)
        // Narration must not keep playing after the user leaves the page it belongs to.
        .onChange(of: activeTab) { _ in
            AudioService.shared.stop()
        }
    }

    // MARK: - Screen router

    @ViewBuilder
    private var screenContent: some View {
        switch activeTab {
        case "species":
            SpeciesDetailView(
                selectedSpeciesId: $selectedSpeciesId,
                activeTab: $activeTab
            )
        case "anatomy":
            AnatomyStageView(
                selectedSpeciesId: $selectedSpeciesId,
                selectedBodyPartId: $selectedBodyPartId,
                activeTab: $activeTab
            )
        case "micro":
            MicroWorldView(
                selectedSpeciesId: $selectedSpeciesId,
                selectedBodyPartId: $selectedBodyPartId,
                activeTab: $activeTab
            )
        case "codex":
            CodexView(
                activeTab: $activeTab,
                selectedSpeciesId: $selectedSpeciesId,
                onUnlockSpecies: { id in
                    if appState.unlock(id) {
                        unlockedSpeciesId = id
                        showUnlockModal = true
                    }
                }
            )
        case "membership":
            MembershipCenterView(
                onOpenPayModal: { showPayModal = true }
            )
        case "profile":
            ProfileView(
                onOpenPayModal: { showPayModal = true }
            )
        default:
            DashboardView(
                activeTab: $activeTab,
                selectedSpeciesId: $selectedSpeciesId,
                onOpenPayModal: { showPayModal = true }
            )
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

            // Navigation Menu Items
            VStack(spacing: 6) {
                SidebarNavItem(id: "dashboard", title: "探索首页", icon: "house.fill", compact: compact, activeTab: $activeTab)
                SidebarNavItem(id: "species", title: "物种档案", icon: "square.grid.2x2.fill", compact: compact, activeTab: $activeTab)
                SidebarNavItem(id: "anatomy", title: "3D 解剖实验室", icon: "viewfinder", compact: compact, activeTab: $activeTab)
                SidebarNavItem(id: "micro", title: "微观视界", icon: "scope", compact: compact, activeTab: $activeTab)
                SidebarNavItem(id: "codex", title: "我的图鉴", icon: "book.closed.fill", compact: compact, activeTab: $activeTab)
                SidebarNavItem(id: "membership", title: "会员中心", icon: "crown.fill", compact: compact, activeTab: $activeTab)
                SidebarNavItem(id: "profile", title: "个人中心", icon: "person.crop.circle.fill", compact: compact, activeTab: $activeTab)
            }
            .padding(.horizontal, compact ? 8 : 12)

            Spacer()

            // Bottom User Status Card
            Button(action: { activeTab = "profile" }) {
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
    let id: String
    let title: String
    let icon: String
    let compact: Bool
    @Binding var activeTab: String

    var isSelected: Bool {
        activeTab == id
    }

    var body: some View {
        Button(action: {
            activeTab = id
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textMuted)
                    .frame(width: 22)

                if !compact {
                    Text(title)
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
        .accessibilityLabel(title)
    }
}
