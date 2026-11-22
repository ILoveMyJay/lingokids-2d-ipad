import Foundation

public struct BodyPart: Identifiable, Hashable, Codable {
    public var id: String
    public let number: Int
    public let nameZh: String
    public let nameEn: String
    public let descZh: String
    public let descEn: String
    public let macroImage: String
    public let hotspotX: Double // 0 - 100%
    public let hotspotY: Double // 0 - 100%
    public let funFactZh: String?

    public init(
        id: String,
        number: Int,
        nameZh: String,
        nameEn: String,
        descZh: String,
        descEn: String,
        macroImage: String,
        hotspotX: Double,
        hotspotY: Double,
        funFactZh: String? = nil
    ) {
        self.id = id
        self.number = number
        self.nameZh = nameZh
        self.nameEn = nameEn
        self.descZh = descZh
        self.descEn = descEn
        self.macroImage = macroImage
        self.hotspotX = hotspotX
        self.hotspotY = hotspotY
        self.funFactZh = funFactZh
    }
}

public struct Species: Identifiable, Hashable, Codable {
    public let id: String
    public let categoryId: String
    public let nameZh: String
    public let nameEn: String
    public let scientificName: String
    public let orderZh: String
    public let familyZh: String
    public let heroImage: String
    public let coverImage: String
    public let length: String
    public let lifespan: String
    public let food: String
    public let habitat: String
    public let overviewZh: String
    public let overviewEn: String
    public let rarity: Int
    public var isUnlocked: Bool
    public var isFavorite: Bool
    public var bodyParts: [BodyPart]

    public init(
        id: String,
        categoryId: String,
        nameZh: String,
        nameEn: String,
        scientificName: String,
        orderZh: String,
        familyZh: String,
        heroImage: String,
        coverImage: String,
        length: String,
        lifespan: String,
        food: String,
        habitat: String,
        overviewZh: String,
        overviewEn: String,
        rarity: Int = 4,
        isUnlocked: Bool = true,
        isFavorite: Bool = false,
        bodyParts: [BodyPart] = []
    ) {
        self.id = id
        self.categoryId = categoryId
        self.nameZh = nameZh
        self.nameEn = nameEn
        self.scientificName = scientificName
        self.orderZh = orderZh
        self.familyZh = familyZh
        self.heroImage = heroImage
        self.coverImage = coverImage
        self.length = length
        self.lifespan = lifespan
        self.food = food
        self.habitat = habitat
        self.overviewZh = overviewZh
        self.overviewEn = overviewEn
        self.rarity = rarity
        self.isUnlocked = isUnlocked
        self.isFavorite = isFavorite
        self.bodyParts = bodyParts
    }
}

public struct SpeciesDataStore {
    /// Decodes species JSON and namespaces body-part IDs as "<speciesId>/<partId>" so they are globally unique.
    public static func decodeSpecies(from data: Data) throws -> [Species] {
        let decoded = try JSONDecoder().decode([Species].self, from: data)
        return namespaceBodyParts(decoded)
    }

    private static func namespaceBodyParts(_ raw: [Species]) -> [Species] {
        raw.map { sp in
            var copy = sp
            copy.bodyParts = sp.bodyParts.map { part in
                var p = part
                if !p.id.hasPrefix("\(sp.id)/") {
                    p.id = "\(sp.id)/\(part.id)"
                }
                return p
            }
            return copy
        }
    }

    private static func locateSpeciesJSON() -> URL? {
        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: "species", withExtension: "json") {
            return url
        }
        if let url = Bundle.module.url(forResource: "species", withExtension: "json", subdirectory: "Data") {
            return url
        }
        #endif

        if let url = Bundle.main.url(forResource: "species", withExtension: "json") {
            return url
        }
        if let url = Bundle.main.url(forResource: "species", withExtension: "json", subdirectory: "Data") {
            return url
        }

        let fm = FileManager.default
        var candidates: [URL] = []
        if let base = Bundle.main.resourceURL {
            candidates.append(base.appendingPathComponent("Resources/species.json"))
            candidates.append(base.appendingPathComponent("Data/species.json"))
        }
        if let dir = ProcessInfo.processInfo.environment["STILLFANTASY_RESOURCES_DIR"], !dir.isEmpty {
            candidates.append(URL(fileURLWithPath: dir).appendingPathComponent("species.json"))
        }
        #if os(macOS)
        let cwd = URL(fileURLWithPath: fm.currentDirectoryPath)
        candidates.append(cwd.appendingPathComponent("Sources/StillFantasyiPad/Data/species.json"))
        candidates.append(cwd.appendingPathComponent("Resources/species.json"))
        #endif

        return candidates.first { fm.fileExists(atPath: $0.path) }
    }

    private static let fallbackSpecies: [Species] = [
        Species(
            id: "blue-morpho",
            categoryId: "insects",
            nameZh: "大蓝闪蝶",
            nameEn: "Blue Morpho Butterfly",
            scientificName: "Morpho peleides",
            orderZh: "昆虫纲",
            familyZh: "自然科",
            heroImage: "images/blue-morpho/hero.jpg",
            coverImage: "images/blue-morpho/cover.jpg",
            length: "翼展 12 - 20 cm",
            lifespan: "成虫约 2 - 3 周",
            food: "熟透发酵的热带水果汁液",
            habitat: "中南美洲热带雨林",
            overviewZh: "大蓝闪蝶翅膀表面具有神奇的物理结构色，在阳光下会绽放出耀眼的金属电光蓝。",
            overviewEn: "The Blue Morpho's wings feature structural color that reflects metallic electric blue in sunlight.",
            rarity: 5,
            isUnlocked: true,
            isFavorite: true,
            bodyParts: []
        )
    ]

    /// All species loaded lazily once from bundled `species.json`.
    public static let sampleSpecies: [Species] = {
        if let url = locateSpeciesJSON(),
           let data = try? Data(contentsOf: url),
           let loaded = try? decodeSpecies(from: data),
           !loaded.isEmpty {
            return loaded
        }
        assertionFailure("Failed to load bundled species.json; falling back to minimal default species.")
        return fallbackSpecies
    }()

    /// O(1) lookup table keyed by species ID.
    private static let speciesById: [String: Species] = {
        Dictionary(uniqueKeysWithValues: sampleSpecies.map { ($0.id, $0) })
    }()

    public static func species(by id: String) -> Species? {
        speciesById[id]
    }

    public static func getSpecies(by id: String) -> Species {
        if let s = speciesById[id] { return s }
        assertionFailure("Unknown species id: \(id)")
        return sampleSpecies[0]
    }
}
