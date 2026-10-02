import Foundation

public struct EcosystemCategory: Identifiable, Hashable {
    public let id: String
    public let nameZh: String
    public let nameEn: String
    public let themeCount: Int
    public let speciesCount: Int
    public let coverImg: String
    public let descZh: String

    public init(id: String, nameZh: String, nameEn: String, themeCount: Int, speciesCount: Int, coverImg: String, descZh: String) {
        self.id = id
        self.nameZh = nameZh
        self.nameEn = nameEn
        self.themeCount = themeCount
        self.speciesCount = speciesCount
        self.coverImg = coverImg
        self.descZh = descZh
    }
}

public struct CategoryDataStore {
    public static let categories: [EcosystemCategory] = [
        EcosystemCategory(
            id: "insects",
            nameZh: "昆虫王国",
            nameEn: "Insect Kingdom",
            themeCount: 8,
            speciesCount: 128,
            coverImg: "images/banners/insects.jpg",
            descZh: "探索微观世界精妙绝伦的盔甲与仿生结构"
        ),
        EcosystemCategory(
            id: "land",
            nameZh: "陆地探险",
            nameEn: "Land Animals",
            themeCount: 6,
            speciesCount: 96,
            coverImg: "images/banners/land.jpg",
            descZh: "领略原野王者与奇兽的生存进化密码"
        ),
        EcosystemCategory(
            id: "ocean",
            nameZh: "深海奇境",
            nameEn: "Ocean Creatures",
            themeCount: 5,
            speciesCount: 78,
            coverImg: "images/banners/ocean.jpg",
            descZh: "畅游蔚蓝深渊，探秘水下神奇发光生命"
        ),
        EcosystemCategory(
            id: "birds",
            nameZh: "鸟类天地",
            nameEn: "Birds World",
            themeCount: 7,
            speciesCount: 102,
            coverImg: "images/banners/birds.jpg",
            descZh: "仰望天际翱翔之羽，破译飞行的空气动力学奇迹"
        )
    ]
}
