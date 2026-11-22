import XCTest
@testable import StillFantasyiPad

final class AppStateTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "com.stillfantasy.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testCheckInSameDayConsecutiveAndMissedDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!

        var currentDate = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 9))!
        let state = AppState(defaults: defaults, calendar: calendar, now: { currentDate })
        let initialStreak = state.streak
        let initialXp = state.xp

        // First check-in
        state.checkIn()
        XCTAssertTrue(state.isCheckedInToday)
        XCTAssertEqual(state.streak, initialStreak + 1)
        XCTAssertEqual(state.xp, initialXp + AppState.checkInReward)

        // Repeated check-in on the same day should be a no-op
        state.checkIn()
        XCTAssertEqual(state.streak, initialStreak + 1)
        XCTAssertEqual(state.xp, initialXp + AppState.checkInReward)

        // Next calendar day increments streak
        currentDate = calendar.date(from: DateComponents(year: 2026, month: 11, day: 2, hour: 8))!
        XCTAssertFalse(state.isCheckedInToday)
        state.checkIn()
        XCTAssertEqual(state.streak, initialStreak + 2)

        // Skipping a day resets streak to 1
        currentDate = calendar.date(from: DateComponents(year: 2026, month: 11, day: 5, hour: 10))!
        state.checkIn()
        XCTAssertEqual(state.streak, 1)
    }

    func testAddXpHandlesMultiLevelUp() {
        let state = AppState(defaults: defaults)
        let startLevel = state.level
        let startXp = state.xp

        state.addXp(AppState.maxXp * 2 + 150)

        let expectedTotal = startXp + AppState.maxXp * 2 + 150
        XCTAssertEqual(state.level, startLevel + expectedTotal / AppState.maxXp)
        XCTAssertEqual(state.xp, expectedTotal % AppState.maxXp)
    }

    func testToggleFavoriteAndUnlockIdempotency() {
        let state = AppState(defaults: defaults)
        let targetId = SpeciesDataStore.sampleSpecies.first(where: { !state.isUnlocked($0.id) })?.id

        if let id = targetId {
            XCTAssertTrue(state.unlock(id))
            XCTAssertFalse(state.unlock(id), "Re-unlocking an already unlocked species must return false")
        }

        let favId = "blue-morpho"
        let before = state.isFavorite(favId)
        state.toggleFavorite(favId)
        XCTAssertEqual(state.isFavorite(favId), !before)
        state.toggleFavorite(favId)
        XCTAssertEqual(state.isFavorite(favId), before)
    }

    func testSpeciesJSONDecodingNamespacesBodyParts() throws {
        let json = """
        [
          {
            "id": "test-beetle",
            "categoryId": "insects",
            "nameZh": "测试甲虫",
            "nameEn": "Test Beetle",
            "scientificName": "Testus beetlus",
            "orderZh": "昆虫纲",
            "familyZh": "自然科",
            "heroImage": "images/test/hero.jpg",
            "coverImage": "images/test/cover.jpg",
            "length": "5 cm",
            "lifespan": "1 年",
            "food": "树汁",
            "habitat": "森林",
            "overviewZh": "测试简介",
            "overviewEn": "Test overview",
            "rarity": 4,
            "isUnlocked": true,
            "isFavorite": false,
            "bodyParts": [
              {
                "id": "horn",
                "number": 1,
                "nameZh": "独角",
                "nameEn": "Horn",
                "descZh": "坚硬的角",
                "descEn": "Hard horn",
                "macroImage": "images/test/horn.jpg",
                "hotspotX": 40.0,
                "hotspotY": 30.0,
                "funFactZh": null
              }
            ]
          }
        ]
        """.data(using: .utf8)!

        let decoded = try SpeciesDataStore.decodeSpecies(from: json)
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded[0].bodyParts.first?.id, "test-beetle/horn")
    }
}
