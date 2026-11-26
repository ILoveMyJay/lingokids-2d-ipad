import SwiftUI

public struct ProfileView: View {
    private enum ActiveSheet: String, Identifiable {
        case footprints
        case audioSettings
        case about
        var id: String { rawValue }
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var audioService = AudioService.shared

    @State private var activeSheet: ActiveSheet?
    @State private var showClearCacheConfirm: Bool = false
    @State private var cacheSizeLabel: String = ""

    public init() {}

    private var userProfile: UserProfile { appState.userProfile }

    private func refreshCacheSize() {
        let totalBytes = ImageCacheService.shared.diskCacheSizeBytes() + AudioCacheStore.shared.diskCacheSizeBytes()
        cacheSizeLabel = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }

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

                        Text("Lv.\(userProfile.level)")
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

                            if userProfile.isVip {
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
                            } else {
                                Button(action: { router.openPayModal() }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "crown")
                                            .font(.system(size: 10))
                                        Text("升级 VIP")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .foregroundColor(Color.goldLight)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.amberGold.opacity(0.2))
                                    .clipShape(Capsule())
                                }
                            }
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

                // MARK: - Settings & Feature Menus (Interactive)
                VStack(spacing: 12) {
                    Button(action: { activeSheet = .footprints }) {
                        SettingRow(
                            icon: "clock.arrow.circlepath",
                            title: "探索足迹与标本记录",
                            desc: appState.recentSpeciesIds.isEmpty
                                ? "暂未留下浏览足迹 · 点击开始探索物种"
                                : "已记录最近探索的 \(appState.recentSpeciesIds.count) 种生物 · 点击回看"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { showClearCacheConfirm = true }) {
                        SettingRow(
                            icon: "externaldrive.fill",
                            title: "离线缓存与媒体管理",
                            desc: "当前本地已缓存 \(cacheSizeLabel.isEmpty ? "计算中..." : cacheSizeLabel)（图片与神经网络原声）· 点击清理"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { activeSheet = .audioSettings }) {
                        SettingRow(
                            icon: "speaker.wave.3.fill",
                            title: "中英双语发音设置",
                            desc: audioService.preferOfflineSystemTTS
                                ? "当前模式：纯离线系统语音（zh-CN / en-GB）"
                                : "当前模式：R2 神经网络原声优先（离线自动降级）"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { activeSheet = .about }) {
                        SettingRow(
                            icon: "info.circle.fill",
                            title: "关于 Still Fantasy 与学术致谢",
                            desc: "版本 v1.1.0 · 已收录 \(SpeciesDataStore.sampleSpecies.count) 种生物与双语原声"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
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
        .onAppear {
            refreshCacheSize()
        }
        .alert("清理离线媒体缓存", isPresented: $showClearCacheConfirm) {
            Button("取消", role: .cancel) {}
            Button("立即清理", role: .destructive) {
                ImageCacheService.shared.clearCache()
                AudioCacheStore.shared.clearCache()
                refreshCacheSize()
            }
        } message: {
            Text("将清空本地磁盘缓存的图片与语音 MP3（当前占用 \(cacheSizeLabel)），下次浏览时会自动重新按需下载。")
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .footprints:
                footprintsSheet
            case .audioSettings:
                audioSettingsSheet
            case .about:
                aboutSheet
            }
        }
    }

    // MARK: - Interactive Sheets

    private var footprintsSheet: some View {
        NavigationStack {
            List {
                if appState.recentSpeciesIds.isEmpty {
                    Text("还没有探索足迹，先去探索首页或图鉴挑一只生物吧！")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(appState.recentSpeciesIds, id: \.self) { id in
                        if let sp = SpeciesDataStore.species(by: id) {
                            Button(action: {
                                activeSheet = nil
                                router.openSpecies(sp.id)
                            }) {
                                HStack(spacing: 12) {
                                    SpecimenImageView(sp.coverImage)
                                        .frame(width: 44, height: 44)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(sp.nameZh)
                                            .font(.headline)
                                        Text("\(sp.nameEn) · \(sp.scientificName)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if appState.isQuizCompleted(sp.id) {
                                        Label("挑战通关", systemImage: "checkmark.seal.fill")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("探索足迹")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") { activeSheet = nil }
                }
            }
        }
    }

    private var audioSettingsSheet: some View {
        NavigationStack {
            Form {
                Section("双语配音引擎") {
                    Toggle("仅使用离线系统合成音", isOn: $audioService.preferOfflineSystemTTS)
                    Text("默认关闭时，优先播放 Cloudflare R2 预录 Edge Neural 高保真原声（中文：晓晓姐姐 / 英文：英伦纪录片大叔 Ryan），无网或未收录音频自动降级为系统语音（en-GB / zh-CN）。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("音频缓存") {
                    LabeledContent("已缓存原声占用", value: AudioCacheStore.shared.formattedDiskCacheSize)
                    Button("清空音频缓存", role: .destructive) {
                        AudioCacheStore.shared.clearCache()
                        refreshCacheSize()
                    }
                }
            }
            .navigationTitle("双语发音设置")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { activeSheet = nil }
                }
            }
        }
    }

    private var aboutSheet: some View {
        NavigationStack {
            List {
                Section("应用信息") {
                    LabeledContent("应用名称", value: "Still Fantasy 暮林幻境")
                    LabeledContent("版本", value: "v1.1.0")
                    LabeledContent("物种百科", value: "\(SpeciesDataStore.sampleSpecies.count) 种")
                    LabeledContent("生态王国", value: "\(CategoryDataStore.categories.count) 大领域")
                }
                Section("媒体与商业化说明") {
                    Text("图文与双语神经网络原声托管于 Cloudflare R2，并支持本地 LRU 磁盘缓存与离线降级。")
                        .font(.caption)
                    Text("当前版本采用微信扫码支付演示流；正式上架 App Store 前将通过 PaymentService 切换为 StoreKit 2 应用内购买。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("关于 Still Fantasy")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") { activeSheet = nil }
                }
            }
        }
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
