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

extension UserProfile {
    /// e.g. "3,000 / 5,000 XP"
    public var xpProgressText: String {
        "\(xp.formatted()) / \(maxXp.formatted()) XP"
    }
}

/// Single source of truth for everything the user changes while using the app
/// (unlocked species, favorites, check-in, XP). Persisted in UserDefaults.
public final class AppState: ObservableObject {
    private enum Key {
        static let unlocked = "sf.unlockedIds"
        static let favorites = "sf.favoriteIds"
        static let lastCheckIn = "sf.lastCheckInDay"
        static let lastCheckInDate = "sf.lastCheckInDate"
        static let streak = "sf.streak"
        static let xp = "sf.xp"
        static let level = "sf.level"
    }

    public static let maxXp = 5000
    public static let checkInReward = 20
    public static let unlockReward = 50

    private let defaults: UserDefaults
    private let calendar: Calendar
    private let now: () -> Date

    @Published public private(set) var unlockedIds: Set<String>
    @Published public private(set) var favoriteIds: Set<String>
    @Published public private(set) var lastCheckInDate: Date?
    @Published public private(set) var streak: Int
    @Published public private(set) var xp: Int
    @Published public private(set) var level: Int

    public init(
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.defaults = defaults
        self.calendar = calendar
        self.now = now
        let all = SpeciesDataStore.sampleSpecies

        if let saved = defaults.array(forKey: Key.unlocked) as? [String] {
            unlockedIds = Set(saved)
        } else {
            unlockedIds = Set(all.filter { $0.isUnlocked }.map { $0.id })
        }
        if let saved = defaults.array(forKey: Key.favorites) as? [String] {
            favoriteIds = Set(saved)
        } else {
            favoriteIds = Set(all.filter { $0.isFavorite }.map { $0.id })
        }

        if let storedDate = defaults.object(forKey: Key.lastCheckInDate) as? Date {
            lastCheckInDate = storedDate
        } else if let legacyDay = defaults.string(forKey: Key.lastCheckIn),
                  let parsed = Self.parseLegacyDay(legacyDay, calendar: calendar) {
            lastCheckInDate = parsed
            defaults.set(parsed, forKey: Key.lastCheckInDate)
        } else {
            lastCheckInDate = nil
        }

        #if DEBUG
        let defaultStreak = 12
        let defaultXp = 3000
        let defaultLevel = 8
        #else
        let defaultStreak = 0
        let defaultXp = 0
        let defaultLevel = 1
        #endif

        streak = defaults.object(forKey: Key.streak) as? Int ?? defaultStreak
        xp = defaults.object(forKey: Key.xp) as? Int ?? defaultXp
        level = defaults.object(forKey: Key.level) as? Int ?? defaultLevel
    }

    // MARK: - Species progress

    public var totalSpeciesCount: Int { SpeciesDataStore.sampleSpecies.count }

    public var unlockedCount: Int {
        SpeciesDataStore.sampleSpecies.filter { unlockedIds.contains($0.id) }.count
    }

    public var explorationProgress: Double {
        totalSpeciesCount == 0 ? 0 : Double(unlockedCount) / Double(totalSpeciesCount)
    }

    public var explorationPercentText: String {
        "\(Int((explorationProgress * 100).rounded()))%"
    }

    public func isUnlocked(_ speciesId: String) -> Bool { unlockedIds.contains(speciesId) }

    public func speciesCount(inCategory categoryId: String) -> Int {
        SpeciesDataStore.sampleSpecies.filter { $0.categoryId == categoryId }.count
    }

    /// Unlocks a species and grants XP. Returns false if it was already unlocked.
    @discardableResult
    public func unlock(_ speciesId: String) -> Bool {
        guard SpeciesDataStore.species(by: speciesId) != nil,
              !unlockedIds.contains(speciesId) else { return false }
        unlockedIds.insert(speciesId)
        defaults.set(unlockedIds.sorted(), forKey: Key.unlocked)
        addXp(Self.unlockReward)
        return true
    }

    // MARK: - Favorites

    public func isFavorite(_ speciesId: String) -> Bool { favoriteIds.contains(speciesId) }

    public func toggleFavorite(_ speciesId: String) {
        if favoriteIds.contains(speciesId) {
            favoriteIds.remove(speciesId)
        } else {
            favoriteIds.insert(speciesId)
        }
        defaults.set(favoriteIds.sorted(), forKey: Key.favorites)
    }

    // MARK: - Daily check-in

    private static func parseLegacyDay(_ day: String, calendar: Calendar) -> Date? {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = calendar.timeZone
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: day)
    }

    public var isCheckedInToday: Bool {
        guard let last = lastCheckInDate else { return false }
        return calendar.isDate(last, inSameDayAs: now())
    }

    public func checkIn() {
        let today = now()
        guard !isCheckedInToday else { return }

        if let last = lastCheckInDate {
            let startOfLast = calendar.startOfDay(for: last)
            let startOfToday = calendar.startOfDay(for: today)
            let daysBetween = calendar.dateComponents([.day], from: startOfLast, to: startOfToday).day ?? 0
            if daysBetween == 1 {
                streak += 1
            } else {
                streak = 1
            }
        } else {
            streak += 1
        }

        lastCheckInDate = today
        defaults.set(today, forKey: Key.lastCheckInDate)
        defaults.set(streak, forKey: Key.streak)
        addXp(Self.checkInReward)
    }

    // MARK: - XP

    public func addXp(_ amount: Int) {
        guard amount > 0 else { return }
        xp += amount
        while xp >= Self.maxXp {
            xp -= Self.maxXp
            level += 1
        }
        defaults.set(xp, forKey: Key.xp)
        defaults.set(level, forKey: Key.level)
    }

    // MARK: - Derived profile for display

    public var userProfile: UserProfile {
        UserProfile(
            level: level,
            levelRankZh: "Lv.\(level) 见习学者",
            xp: xp,
            maxXp: Self.maxXp,
            isCheckedIn: isCheckedInToday,
            discoveredSpecies: unlockedCount,
            totalSpecies: totalSpeciesCount,
            favoritesCount: favoriteIds.count,
            consecutiveDays: streak
        )
    }
}
