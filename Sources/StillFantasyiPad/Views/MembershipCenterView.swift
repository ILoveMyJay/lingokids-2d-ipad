import SwiftUI

public struct MembershipCenterView: View {
    @EnvironmentObject private var appState: AppState
    let onOpenPayModal: () -> Void

    public init(onOpenPayModal: @escaping () -> Void) {
        self.onOpenPayModal = onOpenPayModal
    }

    private var userProfile: UserProfile { appState.userProfile }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header & User Rank
                HStack(alignment: .center) {
                    HStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.amberGold, Color.goldLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 58, height: 58)
                                .background(Circle().fill(Color.darkEmeraldSurface))

                            Text("Lv.8")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(Color.darkEmeraldBg)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.amberGold)
                                .clipShape(Capsule())
                                .offset(x: 4, y: 4)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(userProfile.name)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color.textLight)

                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 11))
                                    Text("VIP PRO 会员")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundColor(Color.darkEmeraldBg)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.goldLight)
                                .clipShape(Capsule())
                            }

                            Text("\(userProfile.title) · 探索经验 \(userProfile.xpProgressText) (连续打卡 \(userProfile.consecutiveDays) 天)")
                                .font(.system(size: 12))
                                .foregroundColor(Color.textMuted)
                        }
                    }

                    Spacer()

                    Button(action: onOpenPayModal) {
                        Text("终身权益生效中")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.biolumMint)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.biolumMint.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.biolumMint.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(20)
                .background(Color.darkEmeraldCard)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )

                // MARK: - VIP Hero Card
                ZStack(alignment: .bottomLeading) {
                    // Background Image / Gradient
                    LinearGradient(
                        colors: [
                            Color(hex: "#143023"),
                            Color(hex: "#0B1D15"),
                            Color(hex: "#07130E")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Color.goldLight)
                                        .font(.system(size: 13))
                                    Text("尊享自然探索者终身计划")
                                        .font(.system(size: 11, weight: .black))
                                        .tracking(1)
                                        .foregroundColor(Color.goldLight)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.amberGold.opacity(0.2))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.amberGold.opacity(0.4), lineWidth: 1))

                                Text("自然探索家 VIP PRO")
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(Color.textLight)

                                Text("解锁全学科自然宇宙、3D 解剖实验室与 800× 显微镜无限成像")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.textMuted)
                            }

                            Spacer()

                            Button(action: onOpenPayModal) {
                                VStack(spacing: 4) {
                                    Text("¥98 / 终身买断")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundColor(Color.darkEmeraldBg)

                                    Text("原价 ¥198 · 限时特惠")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(Color.darkEmeraldBg.opacity(0.8))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color.goldLight, Color.amberGold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: Color.amberGold.opacity(0.4), radius: 15)
                            }
                        }

                        // 4 Privileges Bento
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            PrivilegeCard(icon: "cube.transparent", title: "3D 全景解剖", desc: "\(SpeciesDataStore.sampleSpecies.count) 种生物多层肌理与仿生结构无死角旋转")
                            PrivilegeCard(icon: "waveform.badge.magnifyingglass", title: "1,600+ 原声音频", desc: "高保真雨林生境原声与多语种双语导览讲解")
                            PrivilegeCard(icon: "scope", title: "800× 纳米显微", desc: "电子显微镜级别光子晶体与超疏水表面探秘")
                            PrivilegeCard(icon: "arrow.down.circle.fill", title: "离线全量数据", desc: "支持 361MB 媒体资源离线高速读取，无网畅玩")
                        }
                    }
                    .padding(28)
                }
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [Color.amberGold.opacity(0.5), Color.darkEmeraldBorder],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

                // MARK: - Panoramic Landscape Banner
                ZStack(alignment: .center) {
                    SpecimenImageView("images/banners/ocean.jpg")
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .overlay(Color.darkEmeraldBg.opacity(0.65))

                    VStack(spacing: 8) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 20))
                            .foregroundColor(Color.biolumMint)

                        Text("“每一次观察，都是对自然法则的深情凝视。”")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.textLight)

                        Text("Still Fantasy · 自然之境学者计划")
                            .font(.system(size: 12))
                            .foregroundColor(Color.biolumMint.opacity(0.9))
                    }
                    .padding(20)
                }
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )
            }
            .padding(24)
        }
        .background(Color.darkEmeraldBg)
    }
}

private struct PrivilegeCard: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.goldLight)

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color.textLight)

            Text(desc)
                .font(.system(size: 11))
                .foregroundColor(Color.textMuted)
                .lineSpacing(2)
        }
        .padding(14)
        .background(Color.darkEmeraldBg.opacity(0.7))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.darkEmeraldBorderSubtle, lineWidth: 1)
        )
    }
}
