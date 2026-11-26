#!/usr/bin/env python3
"""
Builds Sources/StillFantasyiPad/Data/species.json from the canonical 50-species
dataset in ../lingokids-2d/scripts/species_data.json while preserving the
iPad flagship Blue Morpho specimen (`blue-morpho`, making 51 species total).

Usage:
    python3 build_full_species_data.py [path/to/lingokids-2d/scripts/species_data.json]
"""
import json
import os
import sys

UNLOCKED_STARTER_IDS = {
    "blue-morpho",
    "monarch-butterfly",
    "rhinoceros-beetle",
    "dragonfly",
    "green-sea-turtle",
    "peregrine-falcon",
    "giant-panda",
    "cheetah",
    "clownfish",
    "honey-bee",
    "hummingbird",
    "fennec-fox",
}

FAVORITE_STARTER_IDS = {
    "blue-morpho",
    "monarch-butterfly",
    "rhinoceros-beetle",
    "giant-panda",
    "green-sea-turtle",
}

RARITY_5_IDS = {
    "blue-morpho",
    "monarch-butterfly",
    "peregrine-falcon",
    "green-sea-turtle",
    "giant-panda",
    "fennec-fox",
    "cheetah",
}

CATEGORY_TAXONOMY = {
    "insects": ("昆虫纲", "节肢昆虫科"),
    "land": ("哺乳纲", "原野奇兽科"),
    "ocean": ("海洋生物纲", "深海生态科"),
    "birds": ("鸟纲", "羽禽飞翔科"),
    "desert": ("荒漠奇境纲", "沙海适应科"),
}

SPECIES_TAXONOMY_OVERRIDES = {
    "honeypot-ant": ("昆虫纲", "蚁科"),
    "desert-hairy-scorpion": ("蛛形纲", "钳蝎科"),
    "web-footed-gecko": ("爬行纲", "壁虎科"),
    "thorny-devil": ("爬行纲", "飞蜥科"),
    "burrowing-owl": ("鸟纲", "鸱鸮科"),
    "fennec-fox": ("哺乳纲", "犬科"),
    "long-eared-hedgehog": ("哺乳纲", "猬科"),
    "dorcas-gazelle": ("哺乳纲", "牛科"),
    "screaming-armadillo": ("哺乳纲", "倭犰狳科"),
    "egyptian-jerboa": ("哺乳纲", "跳鼠科"),
    "green-sea-turtle": ("爬行纲", "海龟科"),
    "octopus": ("头足纲", "章鱼科"),
    "moon-jellyfish": ("钵水母纲", "洋须水母科"),
    "emperor-penguin": ("鸟纲", "企鹅科"),
}

BLUE_MORPHO_FALLBACK = {
    "id": "blue-morpho",
    "categoryId": "insects",
    "nameZh": "大蓝闪蝶",
    "nameEn": "Blue Morpho Butterfly",
    "scientificName": "Morpho peleides",
    "pinyin": "dà lán shǎn dié",
    "nicknameZh": "雨林电光蓝宝石",
    "nicknameEn": "Electric Blue Jewel of the Rainforest",
    "orderZh": "昆虫纲",
    "familyZh": "蛱蝶科",
    "heroImage": "images/blue-morpho/hero.jpg",
    "coverImage": "images/blue-morpho/cover.jpg",
    "length": "翼展 12 - 20 cm (雨林中最大的蝴蝶之一)",
    "lifespan": "成虫约 2 - 3 周 (幼虫阶段约 3 - 4 个月)",
    "food": "熟透发酵的热带水果汁液 (香蕉/芒果/树汁)",
    "habitat": "中南美洲热带雨林、树冠层与溪流两岸",
    "speed": "林间滑翔约 15 km/h",
    "overviewZh": "大蓝闪蝶是世界上最著名的美丽蝴蝶！翅膀表面具有神奇的“物理结构色”，在阳光下会绽放出夺目耀眼的金属电光蓝，犹如一颗在雨林中穿梭飞舞的璀璨蓝宝石。",
    "overviewEn": "The Blue Morpho is one of the most magnificent butterflies on Earth! Its wings feature dazzling structural physical color that reflects brilliant metallic electric blue in sunlight.",
    "rarity": 5,
    "isUnlocked": True,
    "isFavorite": True,
    "bodyParts": [
        {
            "id": "forewings",
            "number": 1,
            "nameZh": "电光蓝前翅",
            "nameEn": "Electric Blue Forewings",
            "pinyin": "diàn guāng lán qián chì",
            "phoneticEn": "/ˈfɔːwɪŋz/",
            "descZh": "巨大的前翅折射出极高饱和度的金属钴蓝色光芒，边缘点缀着黑丝绒边框与白色波浪花纹。",
            "descEn": "Massive forewings shimmering with radiant metallic cobalt-blue iridescence edged by velvet-black borders.",
            "macroImage": "images/blue-morpho/part-1-forewings.jpg",
            "hotspotX": 36.0,
            "hotspotY": 38.0,
            "funFactZh": "前翅的蓝色其实并不是色素，而是纳米鳞片对光波干涉产生的“物理结构色”！",
            "funFactEn": "Its blue color comes from structural interference on nano-scales rather than pigment!",
        },
        {
            "id": "hindwings",
            "number": 2,
            "nameZh": "渐变弧形后翅",
            "nameEn": "Iridescent Hindwings",
            "pinyin": "jiàn biàn hú xíng hòu chì",
            "phoneticEn": "/ˈhaɪndwɪŋz/",
            "descZh": "波浪扇形边缘的后翅，蓝色光泽从天蓝自然渐变到深宝蓝，提供平稳而优雅的滑翔升力。",
            "descEn": "Scalloped hindwings displaying a lush gradient from cyan to royal blue, providing smooth gliding lift.",
            "macroImage": "images/blue-morpho/part-2-hindwings.jpg",
            "hotspotX": 35.0,
            "hotspotY": 64.0,
            "funFactZh": "合拢双翅时，翅背的褐色枯叶纹理能让它瞬间隐身在树干上。",
            "funFactEn": "When closed, the brown underside camouflages the butterfly against tree bark.",
        },
        {
            "id": "structural-scales",
            "number": 3,
            "nameZh": "结构色微观鳞片",
            "nameEn": "Structural Nano-Scales",
            "pinyin": "jié gòu sè lín piàn",
            "phoneticEn": "/skeɪlz/",
            "descZh": "放大 400 倍！像瓦片一样排列的多层纳米阶梯鳞片，专门干涉反射纯蓝光波。",
            "descEn": "Magnified 400x! Overlapping nanoscale ridge scales that physically reflect pure blue light waves.",
            "macroImage": "images/blue-morpho/part-3-scales.jpg",
            "hotspotX": 68.0,
            "hotspotY": 42.0,
            "funFactZh": "科学家正模仿闪蝶鳞片结构，研发无需染料、永不褪色的环保色彩材料与防伪钞票技术。",
            "funFactEn": "Scientists mimic morpho wing scales to build dye-free structural colors and anti-counterfeit tech.",
        },
        {
            "id": "protective-eyespots",
            "number": 4,
            "nameZh": "双色防身眼斑",
            "nameEn": "Protective Eyespots",
            "pinyin": "fáng shēn yǎn bān",
            "phoneticEn": "/ˈaɪspɒts/",
            "descZh": "翅膀背面长有像猫头鹰眼睛一样的一圈圈大眼斑，能在危险时刻威慑掠食小鸟。",
            "descEn": "Concentric circular eyespots along the wing underside that mimic owl eyes to scare away birds.",
            "macroImage": "images/blue-morpho/part-4-eyespots.jpg",
            "hotspotX": 74.0,
            "hotspotY": 62.0,
            "funFactZh": "闪烁的亮蓝与褐底眼斑交替出现，会让追捕的鸟类产生视觉错觉而飞偏方向。",
            "funFactEn": "Alternating bright blue flashes and brown eyespots confuse pursuing birds mid-flight.",
        },
        {
            "id": "proboscis",
            "number": 5,
            "nameZh": "卷曲虹吸口器",
            "nameEn": "Coiled Fruit Proboscis",
            "pinyin": "hóng xī kǒu qì",
            "phoneticEn": "/prəˈbɒsɪs/",
            "descZh": "平时像弹簧卷尺一样盘在脸下，吸食发酵香蕉、芒果汁液时像吸管一样伸展出来。",
            "descEn": "A straw-like coiled proboscis that unrolls to sip fermented fruit juices and tree sap.",
            "macroImage": "images/blue-morpho/part-5-proboscis.jpg",
            "hotspotX": 50.0,
            "hotspotY": 28.0,
            "funFactZh": "和偏爱花蜜的蝴蝶不同，大蓝闪蝶更喜欢吃落地发酵的热带水果汁！",
            "funFactEn": "Unlike flower-sipping butterflies, Blue Morphos prefer fermenting tropical fruit juices!",
        },
        {
            "id": "antennae",
            "number": 6,
            "nameZh": "棒状触角",
            "nameEn": "Clubbed Antennae",
            "pinyin": "bàng zhuàng chù jiǎo",
            "phoneticEn": "/ænˈteniː/",
            "descZh": "头顶两根细长的黑色触角，末端稍微变粗，能嗅探到几百米外热带熟透水果的香气。",
            "descEn": "Slender black antennae with thickened tips that sniff out sweet fruit aromas from far away.",
            "macroImage": "images/blue-morpho/part-6-antennae.jpg",
            "hotspotX": 46.0,
            "hotspotY": 16.0,
            "funFactZh": "棒状触角不仅用来闻味道，还能在飞行中感知气流速度与身体平衡。",
            "funFactEn": "Clubbed antennae detect scents as well as airflow speed and balance during flight.",
        },
        {
            "id": "compound-eyes",
            "number": 7,
            "nameZh": "敏锐复眼",
            "nameEn": "Compound Eyes",
            "pinyin": "mǐn ruì fù yǎn",
            "phoneticEn": "/ˈkɒmpaʊnd aɪz/",
            "descZh": "由成千上万个六角形小眼组成的大黑眼睛，对紫外线和闪烁的蓝光极其敏感。",
            "descEn": "Large faceted compound eyes made of thousands of lenses, finely tuned to UV and flashing blue light.",
            "macroImage": "images/blue-morpho/part-7-compound-eyes.jpg",
            "hotspotX": 54.0,
            "hotspotY": 23.0,
            "funFactZh": "蓝闪蝶飞行时闪烁的金属蓝信号，可以被同伴在雨林上空几百米外识别。",
            "funFactEn": "Flashing blue wing signals can be spotted by other morphos from hundreds of meters away.",
        },
        {
            "id": "thorax",
            "number": 8,
            "nameZh": "毛茸茸胸部",
            "nameEn": "Furry Thorax",
            "pinyin": "xiōng bù",
            "phoneticEn": "/ˈθɔːræks/",
            "descZh": "密布深褐色保暖绒毛的强劲胸部，内部包裹着驱动巨大双翅强力扑打的肌肉群。",
            "descEn": "A furry dark thorax packed with powerful flight muscles that drive its massive flapping wings.",
            "macroImage": "images/blue-morpho/part-8-thorax.jpg",
            "hotspotX": 50.0,
            "hotspotY": 44.0,
            "funFactZh": "清晨阳光刚照进雨林时，闪蝶会展开蓝翅晒太阳给胸部肌肉“热身”！",
            "funFactEn": "Morphos bask in morning sunbeams to warm up the flight muscles inside their thorax.",
        },
        {
            "id": "legs",
            "number": 9,
            "nameZh": "味觉足",
            "nameEn": "Chemosensory Tasting Legs",
            "pinyin": "wèi jué zú",
            "phoneticEn": "/leɡz/",
            "descZh": "细长的小腿末端长有味觉感应细毛，只要脚掌一踩在水果表面，就能立刻“尝”到甜味！",
            "descEn": "Slender legs equipped with chemical sensors on the feet that taste food the moment they land.",
            "macroImage": "images/blue-morpho/part-9-legs.jpg",
            "hotspotX": 48.0,
            "hotspotY": 57.0,
            "funFactZh": "蝴蝶用脚“品尝”味道的灵敏度比人类舌头还要高出许多倍！",
            "funFactEn": "A butterfly's feet taste sweetness far more sensitively than a human tongue!",
        },
        {
            "id": "abdomen",
            "number": 10,
            "nameZh": "深色腹部",
            "nameEn": "Slender Abdomen",
            "pinyin": "fù bù",
            "phoneticEn": "/ˈæbdəmən/",
            "descZh": "位于双翅中间的细长深色腹部，两侧排列着微小呼吸孔（气门），储存能量。",
            "descEn": "The slender segmented dark underbelly housing internal organs and lateral breathing spiracles.",
            "macroImage": "images/blue-morpho/part-10-abdomen.jpg",
            "hotspotX": 50.0,
            "hotspotY": 70.0,
            "funFactZh": "昆虫不用鼻子肺部呼吸，而是靠腹部两侧成对的微型气门直接交换氧气。",
            "funFactEn": "Instead of lungs, butterflies breathe through tiny spiracles along their abdomen.",
        },
    ],
    "quizQuestions": [
        {
            "id": "q1",
            "type": "listen_find",
            "promptZh": "大蓝闪蝶翅膀璀璨的电光蓝色，主要来自哪个纳米级结构？",
            "promptEn": "Which nanoscale structure gives the Blue Morpho its electric blue color?",
            "targetPartId": "structural-scales",
            "options": [
                {"partId": "structural-scales", "textZh": "结构色微观鳞片", "textEn": "Structural Nano-Scales"},
                {"partId": "proboscis", "textZh": "卷曲虹吸口器", "textEn": "Coiled Fruit Proboscis"},
                {"partId": "legs", "textZh": "味觉足", "textEn": "Chemosensory Tasting Legs"},
                {"partId": "abdomen", "textZh": "深色腹部", "textEn": "Slender Abdomen"},
            ],
            "explanationZh": "回答正确！多层纳米阶梯鳞片通过光波干涉反射纯蓝光，这就是神奇的物理结构色。",
            "explanationEn": "Correct! Multilayered nanoscale ridges reflect pure blue light via optical interference.",
        },
        {
            "id": "q2",
            "type": "identify_part",
            "promptZh": "大蓝闪蝶停在熟透的水果上时，用哪个部位瞬间“尝”出甜味？",
            "promptEn": "Which part lets the Blue Morpho instantly taste ripe fruit upon landing?",
            "targetPartId": "legs",
            "options": [
                {"partId": "antennae", "textZh": "棒状触角", "textEn": "Clubbed Antennae"},
                {"partId": "legs", "textZh": "味觉足", "textEn": "Chemosensory Tasting Legs"},
                {"partId": "compound-eyes", "textZh": "敏锐复眼", "textEn": "Compound Eyes"},
                {"partId": "forewings", "textZh": "电光蓝前翅", "textEn": "Electric Blue Forewings"},
            ],
            "explanationZh": "答对了！蝴蝶脚掌末端长满味觉感应细毛，一踩上果汁就能立刻“尝”出味道。",
            "explanationEn": "Well done! Sensory hairs on its feet allow it to taste fruit the instant it lands.",
        },
        {
            "id": "q3",
            "type": "identify_part",
            "promptZh": "当大蓝闪蝶合拢双翅休息时，翅膀背面的什么图案能吓退小鸟？",
            "promptEn": "What pattern on the closed wings helps scare away hungry birds?",
            "targetPartId": "protective-eyespots",
            "options": [
                {"partId": "protective-eyespots", "textZh": "双色防身眼斑", "textEn": "Protective Eyespots"},
                {"partId": "thorax", "textZh": "毛茸茸胸部", "textEn": "Furry Thorax"},
                {"partId": "proboscis", "textZh": "卷曲虹吸口器", "textEn": "Coiled Fruit Proboscis"},
                {"partId": "hindwings", "textZh": "渐变弧形后翅", "textEn": "Iridescent Hindwings"},
            ],
            "explanationZh": "太棒了！像猫头鹰眼睛一样的防身眼斑能威慑捕食者，配合枯叶配色隐身保护自己。",
            "explanationEn": "Awesome! Owl-like eyespots deter predators while brown undersides blend into tree bark.",
        },
    ],
}


def clean_path(path: str) -> str:
    if not path:
        return ""
    return path.strip().lstrip("/")


def convert_web_species(raw: dict) -> dict:
    sp_id = raw["id"]
    cat_id = raw.get("categoryId", "insects")
    order_zh, family_zh = SPECIES_TAXONOMY_OVERRIDES.get(
        sp_id, CATEGORY_TAXONOMY.get(cat_id, ("自然生物纲", "生态科"))
    )
    basic = raw.get("basicInfo", {})

    body_parts = []
    for idx, p in enumerate(raw.get("bodyParts", []), start=1):
        hotspot = p.get("hotspot", {}) or {}
        body_parts.append(
            {
                "id": p["id"],
                "number": int(p.get("number", idx)),
                "nameZh": p.get("nameZh", ""),
                "nameEn": p.get("nameEn", ""),
                "pinyin": p.get("pinyin"),
                "phoneticEn": p.get("phoneticEn"),
                "descZh": p.get("descZh", ""),
                "descEn": p.get("descEn", ""),
                "macroImage": clean_path(p.get("macroImage", "")),
                "hotspotX": float(hotspot.get("x", 50.0)),
                "hotspotY": float(hotspot.get("y", 50.0)),
                "funFactZh": p.get("funFactZh"),
                "funFactEn": p.get("funFactEn"),
            }
        )

    quiz_questions = []
    for q in raw.get("quizQuestions", []):
        options = [
            {
                "partId": opt.get("partId", ""),
                "textZh": opt.get("textZh", ""),
                "textEn": opt.get("textEn", ""),
            }
            for opt in q.get("options", [])
        ]
        quiz_questions.append(
            {
                "id": q.get("id", ""),
                "type": q.get("type", "identify_part"),
                "promptZh": q.get("promptZh", ""),
                "promptEn": q.get("promptEn", ""),
                "targetPartId": q.get("targetPartId", ""),
                "options": options,
                "explanationZh": q.get("explanationZh", ""),
                "explanationEn": q.get("explanationEn", ""),
            }
        )

    return {
        "id": sp_id,
        "categoryId": cat_id,
        "nameZh": raw.get("nameZh", sp_id),
        "nameEn": raw.get("nameEn", sp_id),
        "scientificName": raw.get("scientificName", sp_id),
        "pinyin": raw.get("pinyin"),
        "nicknameZh": raw.get("nicknameZh"),
        "nicknameEn": raw.get("nicknameEn"),
        "orderZh": order_zh,
        "familyZh": family_zh,
        "heroImage": clean_path(raw.get("heroImage", f"images/{sp_id}/hero.jpg")),
        "coverImage": clean_path(raw.get("coverImage", f"images/{sp_id}/cover.jpg")),
        "length": (basic.get("length") or {}).get("zh", "体型适中"),
        "lifespan": (basic.get("lifespan") or {}).get("zh", "数年"),
        "food": (basic.get("food") or {}).get("zh", "自然食性"),
        "habitat": (basic.get("habitat") or {}).get("zh", "自然栖息地"),
        "speed": (basic.get("speed") or {}).get("zh"),
        "overviewZh": raw.get("overviewZh", ""),
        "overviewEn": raw.get("overviewEn", ""),
        "rarity": 5 if sp_id in RARITY_5_IDS else 4,
        "isUnlocked": sp_id in UNLOCKED_STARTER_IDS,
        "isFavorite": sp_id in FAVORITE_STARTER_IDS,
        "bodyParts": body_parts,
        "quizQuestions": quiz_questions,
    }


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    default_web_json = os.path.abspath(
        os.path.join(here, "..", "lingokids-2d", "scripts", "species_data.json")
    )
    src_json = (
        sys.argv[1]
        if len(sys.argv) > 1
        else os.environ.get("LINGOKIDS_SPECIES_JSON", default_web_json)
    )
    if not os.path.exists(src_json):
        print(f"Source species_data.json not found: {src_json}", file=sys.stderr)
        sys.exit(1)

    with open(src_json, "r", encoding="utf-8") as fp:
        web_species = json.load(fp)

    all_species = [convert_web_species(item) for item in web_species]
    if not any(s["id"] == "blue-morpho" for s in all_species):
        all_species.insert(0, BLUE_MORPHO_FALLBACK)

    out_dir = os.path.join(here, "Sources", "StillFantasyiPad", "Data")
    os.makedirs(out_dir, exist_ok=True)
    target_path = os.path.join(out_dir, "species.json")
    with open(target_path, "w", encoding="utf-8") as f:
        json.dump(all_species, f, ensure_ascii=False, indent=2)

    print(f"Total compiled species: {len(all_species)}")
    print(f"Generated {target_path} successfully!")


if __name__ == "__main__":
    main()
