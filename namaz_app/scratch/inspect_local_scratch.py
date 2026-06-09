import os

scratch_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch"

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
    if file.endswith(".dart") or file.endswith(".py"):
        filepath = os.path.join(scratch_dir, file)
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except:
            continue
        
        matches = [kw for kw in keywords if kw in content]
        if matches:
            is_truncated = "<truncated>" in content
            print(f"File {file} (size {os.path.getsize(filepath)}) matches {matches} | truncated: {is_truncated}")
