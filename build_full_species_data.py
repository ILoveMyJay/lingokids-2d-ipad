#!/usr/bin/env python3
import glob
import os
import re

def extract_field(key: str, text: str):
    # Single quoted
    m = re.search(rf"{key}:\s*'((?:[^'\\\\]|\\\\.)*)'", text)
    if m:
        val = m.group(1).replace(r"\'", "'").replace('"', '\\"').replace("\n", " ").strip()
        return val
    # Double quoted
    m = re.search(rf'{key}:\s*"((?:[^"\\\\]|\\\\.)*)"', text)
    if m:
        val = m.group(1).replace(r'\"', '"').replace('"', '\\"').replace("\n", " ").strip()
        return val
    return None

def clean_img_path(path: str) -> str:
    if not path: return ""
    path = path.strip()
    if path.startswith('/'):
        path = path[1:]
    return path

import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
# Usage: python3 build_full_species_data.py [path/to/lingokids-2d/src/data/species]
SPECIES_DIR = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('LINGOKIDS_SPECIES_DIR', os.path.join(HERE, '..', 'lingokids-2d', 'src', 'data', 'species'))
species_files = sorted(glob.glob(os.path.join(SPECIES_DIR, '*.ts')))

all_species = []

for fpath in species_files:
    if fpath.endswith('index.ts'): continue
    with open(fpath, 'r', encoding='utf-8') as fp:
        content = fp.read()
    
    # Split by export const XXX = { or export const XXX: Species = {
    blocks = re.split(r'\bexport const [A-Z0-9_]+(?::\s*Species)?\s*=\s*\{', content)
    for block in blocks[1:]: # skip preamble
        sp_id = extract_field('id', block)
        if not sp_id: continue

        cat_id = extract_field('categoryId', block) or "insects"
        name_zh = extract_field('nameZh', block) or sp_id
        name_en = extract_field('nameEn', block) or sp_id
        sci_name = extract_field('scientificName', block) or sp_id
        hero_img = clean_img_path(extract_field('heroImage', block) or f"images/{sp_id}/hero.jpg")
        cover_img = clean_img_path(extract_field('coverImage', block) or f"images/{sp_id}/cover.jpg")
        
        len_val = extract_field('length', block) or extract_field('zh', block[block.find('length:'):block.find('length:')+200] if 'length:' in block else "") or "体型适中"
        life_val = extract_field('lifespan', block) or extract_field('zh', block[block.find('lifespan:'):block.find('lifespan:')+200] if 'lifespan:' in block else "") or "数年"
        food_val = extract_field('food', block) or extract_field('zh', block[block.find('food:'):block.find('food:')+200] if 'food:' in block else "") or "自然杂食"
        hab_val = extract_field('habitat', block) or extract_field('zh', block[block.find('habitat:'):block.find('habitat:')+200] if 'habitat:' in block else "") or "森林与旷野"
        
        ov_zh = extract_field('overviewZh', block) or "自然界的奇妙生灵。"
        ov_en = extract_field('overviewEn', block) or "A wondrous creature of nature."

        # Body parts
        body_parts = []
        bp_match = re.search(r'bodyParts:\s*\[([\s\S]*?)\]\s*(?:,|\n\s*\})', block)
        if bp_match:
            bp_block = bp_match.group(1)
            raw_parts = bp_block.split('{')
            for rp in raw_parts:
                if 'id:' not in rp: continue
                pid = extract_field('id', rp)
                pnum_m = re.search(r'number:\s*(\d+)', rp)
                pn_zh = extract_field('nameZh', rp)
                pn_en = extract_field('nameEn', rp) or ""
                pd_zh = extract_field('descZh', rp) or ""
                pd_en = extract_field('descEn', rp) or ""
                pimg = clean_img_path(extract_field('macroImage', rp) or "")
                phs_m = re.search(r'hotspot:\s*\{\s*x:\s*(\d+),\s*y:\s*(\d+)', rp)
                pff = extract_field('funFactZh', rp)
                
                if pid and pnum_m and pn_zh:
                    body_parts.append({
                        'id': pid,
                        'number': int(pnum_m.group(1)),
                        'nameZh': pn_zh,
                        'nameEn': pn_en,
                        'descZh': pd_zh,
                        'descEn': pd_en,
                        'macroImage': pimg,
                        'hotspotX': float(phs_m.group(1)) if phs_m else 50.0,
                        'hotspotY': float(phs_m.group(2)) if phs_m else 50.0,
                        'funFactZh': pff
                    })

        order_zh = "昆虫纲"
        family_zh = "自然科"
        if cat_id == "ocean":
            order_zh = "海洋生物纲"
            family_zh = "海洋水族科"
        elif cat_id == "birds":
            order_zh = "鸟纲"
            family_zh = "羽禽科"
        elif cat_id == "land":
            order_zh = "哺乳纲"
            family_zh = "原野奇兽科"

        sp_data = {
            'id': sp_id,
            'categoryId': cat_id,
            'nameZh': name_zh,
            'nameEn': name_en,
            'scientificName': sci_name,
            'orderZh': order_zh,
            'familyZh': family_zh,
            'heroImage': hero_img,
            'coverImage': cover_img,
            'length': len_val,
            'lifespan': life_val,
            'food': food_val,
            'habitat': hab_val,
            'overviewZh': ov_zh,
            'overviewEn': ov_en,
            'rarity': 5 if sp_id in ['blue-morpho', 'monarch-butterfly', 'peregrine-falcon', 'green-sea-turtle', 'giant-panda'] else 4,
            'isUnlocked': sp_id in ['blue-morpho', 'monarch-butterfly', 'rhinoceros-beetle', 'dragonfly', 'green-sea-turtle', 'peregrine-falcon', 'giant-panda', 'cheetah', 'clownfish', 'honey-bee', 'hummingbird'],
            'isFavorite': sp_id in ['blue-morpho', 'monarch-butterfly', 'rhinoceros-beetle', 'giant-panda', 'green-sea-turtle'],
            'bodyParts': body_parts
        }
        all_species.append(sp_data)

# Also ensure 'blue-morpho' exists explicitly if monarch-butterfly is there
morpho_exists = any(s['id'] == 'blue-morpho' for s in all_species)
if not morpho_exists:
    for s in all_species:
        if s['id'] == 'monarch-butterfly':
            clone = dict(s)
            clone['id'] = 'blue-morpho'
            all_species.insert(0, clone)
            break

print(f"Total compiled species: {len(all_species)}")

# Generate Swift code
swift_code = """import Foundation

public struct BodyPart: Identifiable, Hashable {
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

    public init(id: String, number: Int, nameZh: String, nameEn: String, descZh: String, descEn: String, macroImage: String, hotspotX: Double, hotspotY: Double, funFactZh: String? = nil) {
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

public struct Species: Identifiable, Hashable {
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
    private static let rawSpecies: [Species] = [
"""

species_items = []
for sp in all_species:
    parts_code = []
    for bp in sp['bodyParts']:
        ff_str = f'"{bp["funFactZh"]}"' if bp["funFactZh"] else "nil"
        p_str = f"""                BodyPart(
                    id: "{bp['id']}",
                    number: {bp['number']},
                    nameZh: "{bp['nameZh']}",
                    nameEn: "{bp['nameEn']}",
                    descZh: "{bp['descZh']}",
                    descEn: "{bp['descEn']}",
                    macroImage: "{bp['macroImage']}",
                    hotspotX: {bp['hotspotX']:.1f},
                    hotspotY: {bp['hotspotY']:.1f},
                    funFactZh: {ff_str}
                )"""
        parts_code.append(p_str)
    
    parts_join = ",\n".join(parts_code)
    sp_str = f"""        Species(
            id: "{sp['id']}",
            categoryId: "{sp['categoryId']}",
            nameZh: "{sp['nameZh']}",
            nameEn: "{sp['nameEn']}",
            scientificName: "{sp['scientificName']}",
            orderZh: "{sp['orderZh']}",
            familyZh: "{sp['familyZh']}",
            heroImage: "{sp['heroImage']}",
            coverImage: "{sp['coverImage']}",
            length: "{sp['length']}",
            lifespan: "{sp['lifespan']}",
            food: "{sp['food']}",
            habitat: "{sp['habitat']}",
            overviewZh: "{sp['overviewZh']}",
            overviewEn: "{sp['overviewEn']}",
            rarity: {sp['rarity']},
            isUnlocked: {"true" if sp['isUnlocked'] else "false"},
            isFavorite: {"true" if sp['isFavorite'] else "false"},
            bodyParts: [
{parts_join}
            ]
        )"""
    species_items.append(sp_str)

swift_code += ",\n".join(species_items)
swift_code += """
    ]

    /// All species. Body-part IDs are namespaced as "<speciesId>/<partId>" so they are globally unique
    /// (several species share part IDs such as "compound-eyes" / "legs" / "abdomen").
    public static let sampleSpecies: [Species] = rawSpecies.map { sp in
        var copy = sp
        copy.bodyParts = sp.bodyParts.map { part in
            var p = part
            p.id = "\\(sp.id)/\\(part.id)"
            return p
        }
        return copy
    }

    public static func species(by id: String) -> Species? {
        sampleSpecies.first(where: { $0.id == id })
    }

    public static func getSpecies(by id: String) -> Species {
        if let s = species(by: id) { return s }
        assertionFailure("Unknown species id: \\(id)")
        return sampleSpecies[0]
    }
}
"""

target_path = os.path.join(HERE, "Sources", "StillFantasyiPad", "Models", "Species.swift")
with open(target_path, "w", encoding="utf-8") as f:
    f.write(swift_code)

print(f"Generated {target_path} successfully!")
