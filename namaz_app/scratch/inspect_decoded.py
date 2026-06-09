import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
keywords = [
    "Widget _buildKuranKerim",
    "Widget _buildZikirmatik",
    "Widget _buildGunlukDualar",
    "Widget _buildDiniHoca",
    "Widget _buildAylikNamazVakitleri",
    "Widget _buildKibleBulucu",
    "Widget _buildWeekViewChart"
]

for file in os.listdir(scratch_dir):
    if file.startswith("decoded_") and file.endswith(".dart"):
        filepath = os.path.join(scratch_dir, file)
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except:
            continue
        
        matches = [kw for kw in keywords if kw in content]
        if matches:
            # check if it is truncated (i.e. contains the word "<truncated>")
            is_truncated = "<truncated>" in content
            print(f"File {file} (size {os.path.getsize(filepath)}) matches {matches} | truncated: {is_truncated}")
            if not is_truncated:
                print(f"FOUND UNTRUNCATED FILE: {file}!")
