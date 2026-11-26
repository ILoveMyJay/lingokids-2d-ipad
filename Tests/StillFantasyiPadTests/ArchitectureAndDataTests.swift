import XCTest
import CoreGraphics
@testable import StillFantasyiPad

final class ArchitectureAndDataTests: XCTestCase {
    private var tempCacheDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempCacheDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("sf_cache_test_\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempCacheDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempCacheDir {
            try? FileManager.default.removeItem(at: tempCacheDir)
        }
        try super.tearDownWithError()
    }

    func testFullSpeciesDatasetIntegrityAcrossFiveEcosystems() {
        let species = SpeciesDataStore.sampleSpecies
        XCTAssertGreaterThanOrEqual(species.count, 50)

        let ids = species.map { $0.id }
        XCTAssertEqual(Set(ids).count, ids.count, "Species IDs must be unique")

        let categories = Set(species.map { $0.categoryId })
        XCTAssertEqual(categories, Set(["insects", "land", "ocean", "birds", "desert"]))

        for sp in species {
            XCTAssertFalse(sp.bodyParts.isEmpty, "\(sp.id) must have body parts")
            XCTAssertFalse(sp.quizQuestions.isEmpty, "\(sp.id) must have quiz questions")

            let partIds = sp.bodyParts.map { $0.id }
            XCTAssertEqual(Set(partIds).count, partIds.count, "Duplicate part IDs in \(sp.id)")

            for part in sp.bodyParts {
                XCTAssertTrue(part.id.hasPrefix("\(sp.id)/"))
                XCTAssertFalse(part.rawId.contains("/"))
                XCTAssertGreaterThanOrEqual(part.hotspotX, 0.0)
                XCTAssertLessThanOrEqual(part.hotspotX, 100.0)
                XCTAssertGreaterThanOrEqual(part.hotspotY, 0.0)
                XCTAssertLessThanOrEqual(part.hotspotY, 100.0)
            }
        }
    }

    func testAudioPathBuilderAndR2URLBuilder() {
        XCTAssertEqual(
            AudioPathBuilder.speciesOverview(speciesId: "dragonfly", lang: .en),
            "audio/dragonfly/overview_en.mp3"
        )
        XCTAssertEqual(
            AudioPathBuilder.part(speciesId: "dragonfly", rawPartId: "compound-eyes", field: "desc", lang: .zh),
            "audio/dragonfly/parts/part-compound-eyes-desc_zh.mp3"
        )
        XCTAssertEqual(
            AudioPathBuilder.quiz(speciesId: "dragonfly", questionId: "q1", field: "explanation", lang: .en),
            "audio/dragonfly/quiz/quiz-q1-explanation_en.mp3"
        )
        XCTAssertEqual(AudioLanguage.en.speechLocale, "en-GB")

        let url = R2URLBuilder.url(for: "/audio/dragonfly/overview_en.mp3")
        XCTAssertEqual(
            url?.absoluteString,
            "\(R2_ASSET_BASE_URL)/audio/dragonfly/overview_en.mp3"
        )
    }

    func testAppRouterNavigationHelpers() {
        let router = AppRouter()
        router.openCodex(filter: .desert)
        XCTAssertEqual(router.activeTab, .codex)
        XCTAssertEqual(router.codexFilter, .desert)

        router.openQuiz(for: "fennec-fox")
        XCTAssertEqual(router.activeTab, .quiz)
        XCTAssertEqual(router.selectedSpeciesId, "fennec-fox")

        router.openAnatomy(for: "dragonfly", partId: "dragonfly/wings")
        XCTAssertEqual(router.activeTab, .anatomy)
        XCTAssertEqual(router.selectedSpeciesId, "dragonfly")
        XCTAssertEqual(router.selectedBodyPartId, "dragonfly/wings")
    }

    func testAspectFitRectAndHotspotClamping() {
        // 16:9 image inside 800x600 container -> width 800, height 450, centered at y = 75
        let rect = AnatomyStageView.aspectFitRect(
            imageSize: CGSize(width: 1600, height: 900),
            in: CGSize(width: 800, height: 600)
        )
        XCTAssertEqual(rect.origin.x, 0, accuracy: 0.5)
        XCTAssertEqual(rect.origin.y, 75, accuracy: 0.5)
        XCTAssertEqual(rect.width, 800, accuracy: 0.5)
        XCTAssertEqual(rect.height, 450, accuracy: 0.5)

        let centerPart = BodyPart(
            id: "test/center",
            number: 1,
            nameZh: "中心",
            nameEn: "Center",
            descZh: "",
            descEn: "",
            macroImage: "",
            hotspotX: 50,
            hotspotY: 50
        )
        let centerPos = AnatomyStageView.hotspotPosition(
            for: centerPart,
            in: CGSize(width: 800, height: 600),
            imageSize: CGSize(width: 1600, height: 900)
        )
        XCTAssertEqual(centerPos.x, 400, accuracy: 0.5)
        XCTAssertEqual(centerPos.y, 300, accuracy: 0.5)

        let edgePart = BodyPart(
            id: "test/edge",
            number: 2,
            nameZh: "边缘",
            nameEn: "Edge",
            descZh: "",
            descEn: "",
            macroImage: "",
            hotspotX: 0,
            hotspotY: 0
        )
        let edgePos = AnatomyStageView.hotspotPosition(
            for: edgePart,
            in: CGSize(width: 800, height: 600),
            imageSize: CGSize(width: 1600, height: 900),
            edgePadding: 24
        )
        XCTAssertGreaterThanOrEqual(edgePos.x, 24)
        XCTAssertGreaterThanOrEqual(edgePos.y, 75)
    }

    func testAudioCacheStoreLRUEvictionAndClear() {
        let store = AudioCacheStore(cacheDirectory: tempCacheDir, maxDiskBytes: 150)
        let payloadA = Data(repeating: 0x41, count: 100)
        let payloadB = Data(repeating: 0x42, count: 100)

        XCTAssertNotNil(store.store(data: payloadA, for: "audio/a.mp3"))
        Thread.sleep(forTimeInterval: 0.05)
        XCTAssertNotNil(store.store(data: payloadB, for: "audio/b.mp3"))

        XCTAssertLessThanOrEqual(store.diskCacheSizeBytes(), 150)
        XCTAssertNotNil(store.cachedFileURL(for: "audio/b.mp3"))

        store.clearCache()
        XCTAssertEqual(store.diskCacheSizeBytes(), 0)
    }
}
