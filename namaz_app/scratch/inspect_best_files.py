import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
files = os.listdir(scratch_dir)

target_files = [f for f in files if f.startswith("best_") or (f.startswith("decoded_") and f.endswith(".dart"))]

for filename in sorted(target_files):
    filepath = os.path.join(scratch_dir, filename)
    size = os.path.getsize(filepath)
    
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()
        
    print(f"File: {filename} (Size: {size} bytes, Lines: {len(lines)})")
    print("  First 10 lines:")
    for line in lines[:10]:
        try:
            print("    " + line.strip())
        except UnicodeEncodeError:
            # Fallback for console encoding issues on Windows
            print("    " + line.strip().encode('ascii', errors='replace').decode('ascii'))
    print("-" * 50)
