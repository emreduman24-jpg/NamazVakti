import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"

for file in os.listdir(scratch_dir):
    if file.startswith("decoded_") and file.endswith(".dart"):
        filepath = os.path.join(scratch_dir, file)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        if "_buildAylikNamazVakitleri" in content:
            print(f"File {file} (size: {len(content)}) matches _buildAylikNamazVakitleri")
            # print first 10 lines
            lines = content.split('\n')
            print("\n".join(lines[:12]))
            print("=" * 50)
