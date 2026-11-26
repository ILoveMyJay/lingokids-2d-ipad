import SwiftUI

/// Reusable metric card used in species detail Bento grids and sub-info panels.
public struct BentoCard: View {
    public let icon: String
    public let title: String
    public let value: String
    public let desc: String

    public init(icon: String, title: String, value: String, desc: String) {
        self.icon = icon
        self.title = title
        self.value = value
        self.desc = desc
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.biolumMint)
                    .font(.system(size: 14))
                Spacer()
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(Color.textMuted)
            }

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.textLight)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(desc)
                .font(.system(size: 10))
                .foregroundColor(Color.textMuted.opacity(0.8))
                .lineLimit(2)
        }
        .padding(14)
        .background(Color.darkEmeraldCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
        )
    }
}

public struct SubInfoCardData: Identifiable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let value: String
    public let desc: String

    public init(icon: String, title: String, value: String, desc: String) {
        self.icon = icon
        self.title = title
        self.value = value
        self.desc = desc
    }
}

public struct SubInfoPanel: View {
    public let title: String
    public let cards: [SubInfoCardData]
    public let summary: String

    public init(title: String, cards: [SubInfoCardData], summary: String) {
        self.title = title
        self.cards = cards
        self.summary = summary
    }

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 14)
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.textLight)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(cards) { card in
                    BentoCard(
                        icon: card.icon,
                        title: card.title,
                        value: card.value,
                        desc: card.desc
                    )
                }
            }

            Text(summary)
                .font(.system(size: 13))
                .foregroundColor(Color.textMuted)
                .lineSpacing(5)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.darkEmeraldCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                )
        }
    }
}
