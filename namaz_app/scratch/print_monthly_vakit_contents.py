import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"

for file in os.listdir(scratch_dir):
    if file.startswith("decoded_monthlyVakit_") and file.endswith(".dart"):
        filepath = os.path.join(scratch_dir, file)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Check if this contains the actual Dart code for _buildAylikNamazVakitleri
        if "Widget _buildAylikNamazVakitleri() {" in content and "Widget _buildMonthlyListView()" in content:
            print(f"File {file} (size: {len(content)}) matches _buildAylikNamazVakitleri and _buildMonthlyListView!")
            # Print the lines of this file to check if it's full
            print("First 200 chars:")
            print(content[:200])
            print("=" * 50)
