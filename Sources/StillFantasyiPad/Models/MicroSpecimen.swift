import Foundation

public struct MicroSpecimen: Identifiable, Hashable {
    public let id: String
    public let titleZh: String
    public let titleEn: String
    public let categoryZh: String
    public let magnification: String
    public let image: String
    public let descZh: String
    public let descEn: String
    public let tagsZh: [String]

    public init(id: String, titleZh: String, titleEn: String, categoryZh: String, magnification: String, image: String, descZh: String, descEn: String, tagsZh: [String]) {
        self.id = id
        self.titleZh = titleZh
        self.titleEn = titleEn
        self.categoryZh = categoryZh
        self.magnification = magnification
        self.image = image
        self.descZh = descZh
        self.descEn = descEn
        self.tagsZh = tagsZh
    }
}

public struct MicroSpecimenDataStore {
    public static let specimens: [MicroSpecimen] = [
        MicroSpecimen(
            id: "compound-eyes",
            titleZh: "昆虫的复眼",
            titleEn: "Compound Eyes",
            categoryZh: "昆虫器官 · 显微镜",
            magnification: "400×",
            image: "images/blue-morpho/part-7-compound-eyes.jpg",
            descZh: "由成千上万个六角形小眼组成，能够感知光线、颜色和极速动态运动。",
            descEn: "Composed of thousands of hexagonal ommatidia, detecting light and motion.",
            tagsZh: ["六边形小眼透镜", "广角动态视觉", "偏振光感知"]
        ),
        MicroSpecimen(
            id: "wing-scales",
            titleZh: "翅膀鳞片",
            titleEn: "Wing Scales",
            categoryZh: "生物光学 · 显微镜",
            magnification: "400×",
            image: "images/blue-morpho/part-3-scales.jpg",
            descZh: "纳米级多层几丁质阶梯结构，使入射白光发生薄膜干涉，反射出璀璨电光蓝。",
            descEn: "Nanoscale chitin ridges generating interference of light.",
            tagsZh: ["物理结构色", "光子晶体薄膜", "微纳超疏水"]
        ),
        MicroSpecimen(
            id: "pollen-cells",
            titleZh: "花粉细胞",
            titleEn: "Pollen Cells",
            categoryZh: "植物生殖 · 显微镜",
            magnification: "600×",
            image: "images/honey-bee/part-7-pollen-baskets.jpg",
            descZh: "显微镜下宛如微观艺术品的花粉粒，具有独特的几何外壁花纹与微观萌发孔。",
            descEn: "Geometric botanical gems under fluorescence microscopy.",
            tagsZh: ["荧光共聚焦", "微观几何对称", "高效授粉附着"]
        ),
        MicroSpecimen(
            id: "leaf-stomata",
            titleZh: "叶片气孔",
            titleEn: "Leaf Stomata",
            categoryZh: "光合作用 · 显微镜",
            magnification: "800×",
            image: "images/leafcutter-ant/part-3-leaf-piece.jpg",
            descZh: "植物表皮上的微型呼吸阀门，由一对保卫细胞控制开闭，调节水分与气体交换。",
            descEn: "Microscopic breathing pores on leaves controlled by guard cells.",
            tagsZh: ["保卫细胞膨压", "气孔开闭动力学", "光合蒸腾调节"]
        )
    ]
}
