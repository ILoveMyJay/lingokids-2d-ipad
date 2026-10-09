import SwiftUI

public struct UnlockCelebrationView: View {
    @Binding var isPresented: Bool
    let species: Species
    let onNavigateToAnatomy: () -> Void

    public init(isPresented: Binding<Bool>, species: Species, onNavigateToAnatomy: @escaping () -> Void) {
        self._isPresented = isPresented
        self.species = species
        self.onNavigateToAnatomy = onNavigateToAnatomy
    }

    public var body: some View {
        ZStack {
            // Dark Backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 24) {
                // Top Close Button
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.textMuted)
                            .frame(width: 32, height: 32)
                            .background(Color.darkEmeraldSurface)
                            .clipShape(Circle())
                    }
                }

                // Laurel Header
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "laurel.leading")
                            .font(.system(size: 24))
                            .foregroundColor(Color.amberGold)

                        Text("NEW DISCOVERY UNLOCKED")
                            .font(.system(size: 11, weight: .black))
                            .tracking(2)
                            .foregroundColor(Color.goldLight)

                        Image(systemName: "laurel.trailing")
                            .font(.system(size: 24))
                            .foregroundColor(Color.amberGold)
                    }

                    Text("图鉴收录成功！")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Color.textLight)

                    Text("你在探索中破译了全新的自然奥秘，物种档案已永久归档至你的生态图鉴。")
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 360)
                }

                // Specimen Spotlight Card
                VStack(spacing: 12) {
                    SpecimenImageView(species.coverImage)
                        .frame(width: 240, height: 160)
                        .clipped()
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.amberGold, Color.biolumMint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.biolumMint.opacity(0.4), radius: 20)

                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Text(species.nameZh)
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(Color.textLight)

                            HStack(spacing: 2) {
                                ForEach(0..<species.rarity, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.amberGold)
                                }
                            }
                        }

                        Text("\(species.scientificName) · \(species.orderZh) · \(species.familyZh)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.biolumMint)
                    }
                }

                // Rewards Row
                HStack(spacing: 16) {
                    RewardBadge(icon: "bolt.fill", title: "+\(AppState.unlockReward) XP", subtitle: "探索经验加成")
                    RewardBadge(icon: "rosette", title: "\(species.nameZh)勋章", subtitle: "专属探索勋章")
                    RewardBadge(icon: "scope", title: "400× 显微镜", subtitle: "可观察微观结构")
                }

                // Action Buttons
                VStack(spacing: 10) {
                    Button(action: {
                        isPresented = false
                        onNavigateToAnatomy()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "viewfinder")
                                .font(.system(size: 14, weight: .bold))
                            Text("立即前往解剖实验室")
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

                    Button(action: { isPresented = false }) {
                        Text("返回图鉴继续探索")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.textMuted)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(28)
            .background(Color.darkEmeraldBg)
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [Color.amberGold.opacity(0.6), Color.darkEmeraldBorder],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .frame(maxWidth: 460)
            .shadow(color: Color.amberGold.opacity(0.2), radius: 30)
        }
    }
}

private struct RewardBadge: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.amberGold)

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.textLight)

            Text(subtitle)
                .font(.system(size: 9))
                .foregroundColor(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.darkEmeraldCard)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
        )
    }
}
