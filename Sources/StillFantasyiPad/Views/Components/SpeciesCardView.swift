import SwiftUI

/// Unified species grid card handling both unlocked and locked visual states without layout duplication.
public struct SpeciesCardView: View {
    public let species: Species
    public let isUnlocked: Bool
    public let onTap: () -> Void

    public init(species: Species, isUnlocked: Bool, onTap: @escaping () -> Void) {
        self.species = species
        self.isUnlocked = isUnlocked
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                thumbnailSection
                infoSection
            }
            .padding(12)
            .background(Color.darkEmeraldCard.opacity(isUnlocked ? 1.0 : 0.6))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isUnlocked ? Color.darkEmeraldBorder : Color.darkEmeraldBorderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var thumbnailSection: some View {
        if isUnlocked {
            ZStack(alignment: .topTrailing) {
                SpecimenImageView(species.coverImage)
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
        } else {
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
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(species.nameZh)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.textLight.opacity(isUnlocked ? 1.0 : 0.5))

                Spacer()

                if isUnlocked {
                    HStack(spacing: 2) {
                        ForEach(0..<species.rarity, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(Color.amberGold)
                        }
                    }
                } else {
                    Text("待解锁")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.amberGold)
                }
            }

            Text(species.scientificName)
                .font(.system(size: 10, weight: .medium))
                .italic()
                .foregroundColor(isUnlocked ? Color.biolumMint.opacity(0.8) : Color.textMuted.opacity(0.4))

            Text(isUnlocked ? species.overviewZh : "完成生态考察或趣味挑战后收录")
                .font(.system(size: 11))
                .foregroundColor(isUnlocked ? Color.textMuted : Color.textMuted.opacity(0.4))
                .lineLimit(2)
                .padding(.top, 2)
        }
    }
}
