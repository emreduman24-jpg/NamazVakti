import os

tasks_dir = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\tasks"
keywords = ["_buildZikirmatik", "_buildKuranKerim", "_buildGunlukDualar", "_buildDiniHoca", "_buildAylikNamazVakitleri"]

if not os.path.exists(tasks_dir):
    print("Tasks directory does not exist.")
    exit(1)

files = os.listdir(tasks_dir)
print(f"Searching {len(files)} log files...")

matches = []
for filename in files:
    if not filename.endswith(".log"):
        continue
    filepath = os.path.join(tasks_dir, filename)
    
    # Skip extremely large files if they aren't text, but read them in blocks
    try:
        size = os.path.getsize(filepath)
        if size > 10 * 1024 * 1024: # Skip > 10MB
            continue
            
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            for kw in keywords:
                if kw in content:
                    matches.append((filename, kw, size))
    except Exception as e:
        pass

# Print sorted matches
matches.sort(key=lambda x: x[2])
for m in matches:
    print(f"Found keyword '{m[1]}' in {m[0]} (Size: {m[2]} bytes)")
