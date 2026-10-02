import Foundation

public struct UserProfile {
    public var name: String
    public var title: String
    public var level: Int
    public var levelRankZh: String
    public var xp: Int
    public var maxXp: Int
    public var isCheckedIn: Bool
    public var isVip: Bool
    public var vipExpireDate: String
    public var discoveredSpecies: Int
    public var totalSpecies: Int
    public var favoritesCount: Int
    public var achievementBadgesCount: Int
    public var consecutiveDays: Int

    public init(
        name: String = "探索家",
        title: String = "见习学者",
        level: Int = 8,
        levelRankZh: String = "Lv.8 见习学者",
        xp: Int = 3000,
        maxXp: Int = 5000,
        isCheckedIn: Bool = true,
        isVip: Bool = true,
        vipExpireDate: String = "2026-12-31",
        discoveredSpecies: Int = 32,
        totalSpecies: Int = 120,
        favoritesCount: Int = 24,
        achievementBadgesCount: Int = 8,
        consecutiveDays: Int = 12
    ) {
        self.name = name
        self.title = title
        self.level = level
        self.levelRankZh = levelRankZh
        self.xp = xp
        self.maxXp = maxXp
        self.isCheckedIn = isCheckedIn
        self.isVip = isVip
        self.vipExpireDate = vipExpireDate
        self.discoveredSpecies = discoveredSpecies
        self.totalSpecies = totalSpecies
        self.favoritesCount = favoritesCount
        self.achievementBadgesCount = achievementBadgesCount
        self.consecutiveDays = consecutiveDays
    }
}
