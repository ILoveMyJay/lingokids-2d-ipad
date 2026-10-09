import SwiftUI

public struct TopHeaderBar: View {
    @Binding var searchText: String
    let userProfile: UserProfile
    let onOpenProfile: () -> Void

    public init(searchText: Binding<String>, userProfile: UserProfile, onOpenProfile: @escaping () -> Void) {
        self._searchText = searchText
        self.userProfile = userProfile
        self.onOpenProfile = onOpenProfile
    }

    public var body: some View {
        HStack(spacing: 16) {
            // Search Pill
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.textMuted.opacity(0.6))
                    .font(.system(size: 14))

                TextField("搜索物种名称、英文名或学名...", text: $searchText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.textLight)
                    .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.textMuted.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.darkEmeraldCard.opacity(0.9))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.darkEmeraldBorder, lineWidth: 1)
            )
            .frame(maxWidth: 360)

            Spacer()

            // User Profile Trigger Button
            Button(action: onOpenProfile) {
                HStack(spacing: 8) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .stroke(
                                LinearGradient(colors: [Color.amberGold, Color.goldLight], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Color.darkEmeraldSurface))

                        Text("\(userProfile.level)")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(Color.darkEmeraldBg)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.amberGold)
                            .clipShape(Capsule())
                            .offset(x: 4, y: 2)
                    }

                    Text(userProfile.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.textLight)
                }
                .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.darkEmeraldBg.opacity(0.85))
    }
}


/// Dropdown shown under the header while the search field is non-empty.
public struct SearchResultsView: View {
    let query: String
    let isUnlocked: (String) -> Bool
    let onSelect: (Species) -> Void

    private var results: [Species] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return SpeciesDataStore.sampleSpecies.filter {
            $0.nameZh.lowercased().contains(q)
                || $0.nameEn.lowercased().contains(q)
                || $0.scientificName.lowercased().contains(q)
                || $0.orderZh.contains(q)
        }
    }

    public var body: some View {
        let items = results
        VStack(alignment: .leading, spacing: 0) {
            if items.isEmpty {
                Text("没有找到相关物种")
                    .font(.system(size: 13))
                    .foregroundColor(Color.textMuted)
                    .padding(16)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(items.prefix(8)) { sp in
                            Button(action: { onSelect(sp) }) {
                                HStack(spacing: 12) {
                                    SpecimenImageView(sp.coverImage)
                                        .frame(width: 36, height: 36)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(sp.nameZh)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(Color.textLight)
                                        Text("\(sp.nameEn) · \(sp.scientificName)")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.textMuted)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    if !isUnlocked(sp.id) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color.amberGold)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(maxHeight: 380)
            }
        }
        .frame(width: 360)
        .background(Color.darkEmeraldCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 16, y: 6)
    }
}
