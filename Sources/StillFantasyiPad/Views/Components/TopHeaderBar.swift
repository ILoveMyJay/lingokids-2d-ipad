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

                TextField("搜索植物、动物、微观世界...", text: $searchText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.textLight)
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

            // AR Scan Button
            Button(action: {}) {
                Image(systemName: "viewfinder")
                    .foregroundColor(Color.textMuted)
                    .font(.system(size: 15))
                    .frame(width: 36, height: 36)
                    .background(Color.darkEmeraldCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.darkEmeraldBorder, lineWidth: 1))
            }

            // Notification Bell with Ping
            Button(action: {}) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .foregroundColor(Color.textMuted)
                        .font(.system(size: 15))
                        .frame(width: 36, height: 36)
                        .background(Color.darkEmeraldCard)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.darkEmeraldBorder, lineWidth: 1))

                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: -2, y: 4)
                }
            }

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
