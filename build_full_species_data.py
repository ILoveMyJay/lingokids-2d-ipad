#!/usr/bin/env python3
"""
Compiles TypeScript species data from lingokids-2d into
Sources/StillFantasyiPad/Data/species.json for lazy Codable loading in Swift.

Usage:
    python3 build_full_species_data.py [path/to/lingokids-2d/src/data/species]
"""
import glob
import json
import os
import re
import sys


def extract_field(key: str, text: str):
    # Single quoted
    m = re.search(rf"{key}:\s*'((?:[^'\\]|\\.)*)'", text)
    if m:
        val = m.group(1).replace(r"\'", "'").replace("\n", " ").strip()
        return val
    # Double quoted
    m = re.search(rf'{key}:\s*"((?:[^"\\]|\\.)*)"', text)
    if m:
        val = m.group(1).replace(r'\"', '"').replace("\n", " ").strip()
        return val
    return None


def clean_img_path(path: str) -> str:
    if not path:
        return ""
    path = path.strip()
    if path.startswith("/"):
        path = path[1:]
    return path


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    species_dir = (
        sys.argv[1]
        if len(sys.argv) > 1
        else os.environ.get(
            "LINGOKIDS_SPECIES_DIR",
            os.path.join(here, "..", "lingokids-2d", "src", "data", "species"),
        )
    )
    species_files = sorted(glob.glob(os.path.join(species_dir, "*.ts")))
    if not species_files:
        print(f"No .ts species files found in {species_dir}", file=sys.stderr)
        sys.exit(1)

    all_species = []
    for fpath in species_files:
        if fpath.endswith("index.ts"):
            continue
        with open(fpath, "r", encoding="utf-8") as fp:
            content = fp.read()

        blocks = re.split(
            r"\bexport const [A-Z0-9_]+(?::\s*Species)?\s*=\s*\{", content
        )
        for block in blocks[1:]:
            sp_id = extract_field("id", block)
            if not sp_id:
                continue

            cat_id = extract_field("categoryId", block) or "insects"
            name_zh = extract_field("nameZh", block) or sp_id
            name_en = extract_field("nameEn", block) or sp_id
            sci_name = extract_field("scientificName", block) or sp_id
            hero_img = clean_img_path(
                extract_field("heroImage", block) or f"images/{sp_id}/hero.jpg"
            )
            cover_img = clean_img_path(
                extract_field("coverImage", block) or f"images/{sp_id}/cover.jpg"
            )

            len_val = (
                extract_field("length", block)
                or extract_field(
                    "zh",
                    block[block.find("length:") : block.find("length:") + 200]
                    if "length:" in block
                    else "",
                )
                or "体型适中"
            )
            life_val = (
                extract_field("lifespan", block)
                or extract_field(
                    "zh",
                    block[block.find("lifespan:") : block.find("lifespan:") + 200]
                    if "lifespan:" in block
                    else "",
                )
                or "数年"
            )
            food_val = (
                extract_field("food", block)
                or extract_field(
                    "zh",
                    block[block.find("food:") : block.find("food:") + 200]
                    if "food:" in block
                    else "",
                )
                or "自然杂食"
            )
            hab_val = (
                extract_field("habitat", block)
                or extract_field(
                    "zh",
                    block[block.find("habitat:") : block.find("habitat:") + 200]
                    if "habitat:" in block
                    else "",
                )
                or "森林与旷野"
            )

            ov_zh = extract_field("overviewZh", block) or "自然界的奇妙生灵。"
            ov_en = extract_field("overviewEn", block) or "A wondrous creature of nature."

            body_parts = []
            bp_match = re.search(r"bodyParts:\s*\[([\s\S]*?)\]\s*(?:,|\n\s*\})", block)
            if bp_match:
                bp_block = bp_match.group(1)
                for rp in bp_block.split("{"):
                    if "id:" not in rp:
                        continue
                    pid = extract_field("id", rp)
                    pnum_m = re.search(r"number:\s*(\d+)", rp)
                    pn_zh = extract_field("nameZh", rp)
                    pn_en = extract_field("nameEn", rp) or ""
                    pd_zh = extract_field("descZh", rp) or ""
                    pd_en = extract_field("descEn", rp) or ""
                    pimg = clean_img_path(extract_field("macroImage", rp) or "")
                    phs_m = re.search(r"hotspot:\s*\{\s*x:\s*(\d+),\s*y:\s*(\d+)", rp)
                    pff = extract_field("funFactZh", rp)

                    if pid and pnum_m and pn_zh:
                        body_parts.append(
                            {
                                "id": pid,
                                "number": int(pnum_m.group(1)),
                                "nameZh": pn_zh,
                                "nameEn": pn_en,
                                "descZh": pd_zh,
                                "descEn": pd_en,
                                "macroImage": pimg,
                                "hotspotX": float(phs_m.group(1)) if phs_m else 50.0,
                                "hotspotY": float(phs_m.group(2)) if phs_m else 50.0,
                                "funFactZh": pff,
                            }
                        )

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

            all_species.append(
                {
                    "id": sp_id,
                    "categoryId": cat_id,
                    "nameZh": name_zh,
                    "nameEn": name_en,
                    "scientificName": sci_name,
                    "orderZh": order_zh,
                    "familyZh": family_zh,
                    "heroImage": hero_img,
                    "coverImage": cover_img,
                    "length": len_val,
                    "lifespan": life_val,
                    "food": food_val,
                    "habitat": hab_val,
                    "overviewZh": ov_zh,
                    "overviewEn": ov_en,
                    "rarity": 5
                    if sp_id
                    in [
                        "blue-morpho",
                        "monarch-butterfly",
                        "peregrine-falcon",
                        "green-sea-turtle",
                        "giant-panda",
                    ]
                    else 4,
                    "isUnlocked": sp_id
                    in [
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
                    ],
                    "isFavorite": sp_id
                    in [
                        "blue-morpho",
                        "monarch-butterfly",
                        "rhinoceros-beetle",
                        "giant-panda",
                        "green-sea-turtle",
                    ],
                    "bodyParts": body_parts,
                }
            )

    if not any(s["id"] == "blue-morpho" for s in all_species):
        for s in all_species:
            if s["id"] == "monarch-butterfly":
                clone = dict(s)
                clone["id"] = "blue-morpho"
                all_species.insert(0, clone)
                break

    out_dir = os.path.join(here, "Sources", "StillFantasyiPad", "Data")
    os.makedirs(out_dir, exist_ok=True)
    target_path = os.path.join(out_dir, "species.json")
    with open(target_path, "w", encoding="utf-8") as f:
        json.dump(all_species, f, ensure_ascii=False, indent=2)

    print(f"Total compiled species: {len(all_species)}")
    print(f"Generated {target_path} successfully!")


if __name__ == "__main__":
    main()
