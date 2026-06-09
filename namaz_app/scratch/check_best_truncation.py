import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
best_files = [
    "best_buildAylikNamazVakitleri.dart",
    "best_buildDiniHoca.dart",
    "best_buildGunlukDualar.dart",
    "best_buildKuranKerim.dart",
    "best_buildZikirmatik.dart"
]

for filename in best_files:
    filepath = os.path.join(scratch_dir, filename)
    if not os.path.exists(filepath):
        print(f"File {filename} does not exist.")
        continue
        
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
        
    has_trunc = "truncated" in content or "TRUNCATED" in content or "<truncated" in content
    print(f"File: {filename} | Length: {len(content)} chars | Has Truncation: {has_trunc}")
