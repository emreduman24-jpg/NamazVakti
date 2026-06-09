import os

filepath = r"C:\Users\kral_\.gemini\antigravity\scratch\peygamber_hayati_flutter.dart"
if os.path.exists(filepath):
    print("File exists, size:", os.path.getsize(filepath))
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    keywords = [
        "Widget _buildKuranKerim",
        "Widget _buildZikirmatik",
        "Widget _buildGunlukDualar",
        "Widget _buildDiniHoca",
        "Widget _buildAylikNamazVakitleri",
        "Widget _buildKibleBulucu",
        "Widget _buildWeekViewChart"
    ]
    for kw in keywords:
        if kw in content:
            print(f"Found keyword: {kw}")
        else:
            print(f"NOT found: {kw}")
else:
    print("File does not exist")
