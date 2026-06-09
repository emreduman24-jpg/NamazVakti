import os

steps_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_steps"

keywords = [
    "_buildKibleBulucu",
    "_buildZikirmatik",
    "_buildKuranKerim",
    "_buildGunlukDualar",
    "_buildDiniHoca",
    "_buildAylikNamazVakitleri",
    "_buildProphet"
]

for filename in os.listdir(steps_dir):
    if not filename.endswith(".txt"):
        continue
    filepath = os.path.join(steps_dir, filename)
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    matches = []
    for kw in keywords:
        if kw in content:
            matches.append(kw)
    if matches:
        print(f"File {filename} (size {len(content)}) matches: {matches}")
