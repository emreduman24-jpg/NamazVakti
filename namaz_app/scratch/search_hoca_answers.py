import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
# search in all decoded_hoca or similar files for answers or mock replies

for file in os.listdir(scratch_dir):
    if "hoca" in file.lower() or "soru" in file.lower():
        filepath = os.path.join(scratch_dir, file)
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            if "cevap" in content or "answer" in content or "Case" in content or "case" in content:
                print(f"File {file} size {len(content)} matches")
                # print lines that contain "case" or "if" or "cevap"
                lines = content.split('\n')
                for line in lines:
                    if 'case' in line or 'if (' in line or 'else if' in line or 'return' in line:
                        if len(line.strip()) > 10:
                            print("  ", line.strip())
                print("=" * 30)
        except:
            continue
