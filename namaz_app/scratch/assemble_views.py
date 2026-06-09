import os
import re

views_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_view_contents"
files = os.listdir(views_dir)

keywords = [
    "_buildKuranKerim",
    "_buildZikirmatik",
    "_buildGunlukDualar",
    "_buildDiniHoca",
    "_buildAylikNamazVakitleri",
    "_buildKibleBulucu"
]

results = {kw: [] for kw in keywords}

for filename in files:
    if not filename.endswith(".txt"):
        continue
    filepath = os.path.join(views_dir, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
        for kw in keywords:
            if kw in content:
                # Find step index from filename
                parts = filename.split("_")
                step = int(parts[1])
                results[kw].append((step, filename))

# Sort by step index
for kw in keywords:
    results[kw].sort(key=lambda x: x[0])
    print(f"\nKeyword: {kw}")
    if not results[kw]:
        print("  No matches found.")
    else:
        for step, filename in results[kw][-5:]:
            print(f"  Step {step}: {filename}")
