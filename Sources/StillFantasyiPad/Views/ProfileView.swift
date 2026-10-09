import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    let onOpenPayModal: () -> Void

    public init(onOpenPayModal: @escaping () -> Void) {
        self.onOpenPayModal = onOpenPayModal
    }

    private var userProfile: UserProfile { appState.userProfile }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Identity Card
                HStack(alignment: .center, spacing: 20) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.amberGold, Color.goldLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3.5
                            )
                            .frame(width: 72, height: 72)
                            .background(Circle().fill(Color.darkEmeraldSurface))

                        Text("Lv.8")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Color.darkEmeraldBg)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.amberGold)
                            .clipShape(Capsule())
                            .offset(x: 4, y: 4)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(userProfile.name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color.textLight)

                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10))
                                Text("VIP PRO 终身")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(Color.darkEmeraldBg)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.goldLight)
                            .clipShape(Capsule())
                        }

                        Text("自然\(userProfile.title) · 探索经验 \(userProfile.xpProgressText)")
                            .font(.system(size: 13))
                            .foregroundColor(Color.textMuted)

                        Text("会员有效期：\(userProfile.vipExpireDate)")
                            .font(.system(size: 11))
                            .foregroundColor(Color.biolumMint.opacity(0.8))
                    }

                    Spacer()

                    // Check-in Button
                    Button(action: {
                        appState.checkIn()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: userProfile.isCheckedIn ? "checkmark.circle.fill" : "calendar.badge.clock")
                                .font(.system(size: 13))
                            Text(userProfile.isCheckedIn ? "今日已打卡 +\(AppState.checkInReward) XP" : "每日打卡 +\(AppState.checkInReward) XP")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(Color.darkEmeraldBg)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.biolumMint.opacity(userProfile.isCheckedIn ? 0.55 : 1))
                        .clipShape(Capsule())
                    }
                    .disabled(userProfile.isCheckedIn)
                }
                .padding(24)
                .background(Color.darkEmeraldCard)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )

                // MARK: - 4 Stats Counter Row
                HStack(spacing: 16) {
                    StatCard(value: "\(userProfile.discoveredSpecies)", label: "已收录物种", icon: "book.closed.fill")
                    StatCard(value: "\(userProfile.achievementBadgesCount)", label: "探索成就勋章", icon: "rosette")
                    StatCard(value: "\(userProfile.favoritesCount)", label: "已收藏生物", icon: "heart.fill")
                    StatCard(value: "\(userProfile.consecutiveDays) 天", label: "连续探索天数", icon: "flame.fill")
                }

                // MARK: - Settings & Feature Menus
                VStack(spacing: 12) {
                    SettingRow(icon: "clock.arrow.circlepath", title: "探索足迹与标本记录", desc: "查看最近浏览与解剖实验室操作记录")
                    SettingRow(icon: "externaldrive.fill", title: "离线全量数据包管理", desc: "本地缓存已占用 361 MB · 支持离线高清音频与显微切片")
                    SettingRow(icon: "speaker.wave.3.fill", title: "中英双语发音设置", desc: "当前模式：标准中英双语学术朗读")
                    SettingRow(icon: "info.circle.fill", title: "关于 Still Fantasy 与学术致谢", desc: "版本 v1.0.0 · 谨以此致敬大自然的造物奇迹")
                }

                // MARK: - Atmospheric Canyon Illustration Banner
                ZStack(alignment: .bottomLeading) {
                    SpecimenImageView("images/blue-morpho/hero.jpg")
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.darkEmeraldBg.opacity(0.3),
                                    Color.darkEmeraldBg.opacity(0.85)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("致敬未知的微观自然之美")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.textLight)

                        Text("在每一个看似渺小的细胞与翅脉中，都潜藏着漫长亿万年演化凝练的诗篇。")
                            .font(.system(size: 12))
                            .foregroundColor(Color.textMuted)
                    }
                    .padding(24)
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

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.biolumMint)

            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(Color.textLight)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.darkEmeraldCard)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
        )
    }
}

private struct SettingRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.biolumMint)
                .frame(width: 36, height: 36)
                .background(Color.darkEmeraldSurface)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.textLight)

                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(Color.textMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.textMuted.opacity(0.6))
        }
        .padding(16)
        .background(Color.darkEmeraldCard)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
        )
    }
}
