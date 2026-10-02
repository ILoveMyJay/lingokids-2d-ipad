import SwiftUI

public struct MainLayoutView: View {
    @State private var activeTab: String = "dashboard"
    @State private var selectedSpeciesId: String = "blue-morpho"
    @State private var selectedBodyPartId: String? = "blue-morpho-part-1"
    @State private var searchText: String = ""
    @State private var userProfile = UserProfile()

    // Modals
    @State private var showPayModal: Bool = false
    @State private var showUnlockModal: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            Color.darkEmeraldBg.ignoresSafeArea()

            HStack(spacing: 0) {
                // MARK: - Left iPad Sidebar
                VStack(alignment: .leading, spacing: 20) {
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
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Divider().background(Color.darkEmeraldBorder)

                    // Navigation Menu Items
                    VStack(spacing: 6) {
                        SidebarNavItem(id: "dashboard", title: "探索首页", icon: "house.fill", activeTab: $activeTab)
                        SidebarNavItem(id: "species", title: "物种档案", icon: "square.grid.2x2.fill", activeTab: $activeTab)
                        SidebarNavItem(id: "anatomy", title: "3D 解剖实验室", icon: "viewfinder", activeTab: $activeTab)
                        SidebarNavItem(id: "micro", title: "微观视界", icon: "scope", activeTab: $activeTab)
                        SidebarNavItem(id: "codex", title: "我的图鉴", icon: "book.closed.fill", activeTab: $activeTab)
                        SidebarNavItem(id: "membership", title: "会员中心", icon: "crown.fill", activeTab: $activeTab)
                        SidebarNavItem(id: "profile", title: "个人中心", icon: "person.crop.circle.fill", activeTab: $activeTab)
                    }
                    .padding(.horizontal, 12)

                    Spacer()

                    // Bottom User Status Card
                    Button(action: { activeTab = "profile" }) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.darkEmeraldSurface)
                                    .frame(width: 36, height: 36)
                                    .overlay(Circle().stroke(Color.amberGold, lineWidth: 1.5))

                                Text("8")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundColor(Color.goldLight)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(userProfile.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color.textLight)

                                    Text("VIP")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(Color.darkEmeraldBg)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.goldLight)
                                        .clipShape(Capsule())
                                }

                                Text("3,000 / 5,000 XP")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color.textMuted)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.textMuted.opacity(0.6))
                        }
                        .padding(12)
                        .background(Color.darkEmeraldCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                }
                .frame(width: 240)
                .background(Color.darkEmeraldSurface)
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.darkEmeraldBorder),
                    alignment: .trailing
                )

                // MARK: - Right Detail Area
                VStack(spacing: 0) {
                    TopHeaderBar(
                        searchText: $searchText,
                        userProfile: userProfile,
                        onOpenProfile: { activeTab = "profile" }
                    )

                    Divider().background(Color.darkEmeraldBorder)

                    // Switchable Screen Views
                    ZStack {
                        switch activeTab {
                        case "dashboard":
                            DashboardView(
                                activeTab: $activeTab,
                                selectedSpeciesId: $selectedSpeciesId,
                                onOpenPayModal: { showPayModal = true }
                            )
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
                                onTriggerUnlockModal: { showUnlockModal = true }
                            )
                        case "membership":
                            MembershipCenterView(
                                userProfile: userProfile,
                                onOpenPayModal: { showPayModal = true }
                            )
                        case "profile":
                            ProfileView(
                                userProfile: userProfile,
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    onNavigateToAnatomy: {
                        selectedSpeciesId = "blue-morpho"
                        activeTab = "anatomy"
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeTab)
        .animation(.easeInOut(duration: 0.25), value: showPayModal)
        .animation(.easeInOut(duration: 0.25), value: showUnlockModal)
    }
}

private struct SidebarNavItem: View {
    let id: String
    let title: String
    let icon: String
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

                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textLight)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
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
    }
}
