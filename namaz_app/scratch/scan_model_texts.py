import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
keywords = {
    "_buildKuranKerim": [],
    "_buildZikirmatik": [],
    "_buildGunlukDualar": [],
    "_buildDiniHoca": [],
    "_buildAylikNamazVakitleri": [],
    "_buildKibleBulucu": [],
    "_buildWeekViewChart": []
}

for file in os.listdir(scratch_dir):
    if file.startswith("model_text_") and file.endswith(".txt"):
        filepath = os.path.join(scratch_dir, file)
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except:
            continue
        
        for kw in keywords:
            if kw in content:
                is_truncated = "<truncated>" in content
                keywords[kw].append((file, len(content), is_truncated))

for kw, matches in keywords.items():
    print(f"Keyword '{kw}' found in:")
    for file, size, trunc in sorted(matches, key=lambda x: x[1], reverse=True):
        print(f"  - {file} (size: {size}, truncated: {trunc})")
