import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
files = os.listdir(scratch_dir)

print("Large files in root scratch folder:")
for filename in files:
    filepath = os.path.join(scratch_dir, filename)
    if os.path.isdir(filepath):
        continue
    size = os.path.getsize(filepath)
    if size > 40 * 1024:
        print(f"File: {filename} (Size: {size} bytes)")
        
        # Read the file and check for our key build methods
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
            
        keywords = [
            "_buildZikirmatik",
            "_buildKuranKerim",
            "_buildGunlukDualar",
            "_buildDiniHoca",
            "_buildAylikNamazVakitleri",
            "_buildKibleBulucu"
        ]
        
        found = [kw for kw in keywords if kw in content]
        print(f"  Keywords found: {found}")
        # Print first 2 lines and last 2 lines of first 1000 characters
        try:
            print("  First 200 chars:", content[:200].replace('\n', ' '))
        except UnicodeEncodeError:
            print("  First 200 chars:", content[:200].replace('\n', ' ').encode('ascii', errors='replace').decode('ascii'))
        print("-" * 50)
