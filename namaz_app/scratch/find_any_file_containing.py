import os

search_paths = [
    r"c:\Users\kral_\Namaz vakitleri",
    r"C:\Users\kral_\.gemini\antigravity"
]

target_strings = [
    "Bu Haftanın Zikir Takibi",
    "bu_haftanin_zikir_takibi",
    "_buildWeekViewChart",
    "Kaldığın Yer",
    "Kur'an Duaları",
    "Dini Hoca",
    "Aylık Namaz Vakitleri",
    "_buildAylikNamazVakitleri"
]

print("Searching system for past code fragments...")

for base_path in search_paths:
    if not os.path.exists(base_path):
        continue
    for root, dirs, files in os.walk(base_path):
        # Skip node_modules and .git
        if "node_modules" in root or ".git" in root or "extracted_steps" in root:
            continue
        for file in files:
            if file.endswith((".dart", ".txt", ".json", ".js", ".py")):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                except:
                    continue
                
                matches = [s for s in target_strings if s in content]
                if matches:
                    print(f"Match found in: {filepath} (Matches: {matches})")
