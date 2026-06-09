import os
import json
import re

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
best_files = [
    "best_buildAylikNamazVakitleri.dart",
    "best_buildDiniHoca.dart",
    "best_buildGunlukDualar.dart",
    "best_buildKuranKerim.dart",
    "best_buildZikirmatik.dart"
]

for filename in best_files:
    filepath = os.path.join(scratch_dir, filename)
    if not os.path.exists(filepath):
        print(f"File {filename} does not exist.")
        continue
        
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
        
    def safe_print(text):
        try:
            print(text)
        except UnicodeEncodeError:
            print(text.encode('ascii', errors='replace').decode('ascii'))

    safe_print(f"=== {filename} (Size: {len(content)} chars) ===")
    safe_print("Is it log/JSON format? Let's check first 200 chars:")
    safe_print(content[:200].replace('\n', ' '))
    
    is_log = "===================" in content or '"arguments"' in content or '"ReplacementContent"' in content
    safe_print(f"Detected as log file: {is_log}")
    
    if is_log:
        safe_print("  Extracting code blocks from logs...")
        code_blocks = []
        
        matches_rep = re.findall(r'"ReplacementContent"\s*:\s*"((?:[^"\\]|\\.)*)"', content)
        for m in matches_rep:
            unescaped = m.replace('\\n', '\n').replace('\\"', '"').replace("\\'", "'").replace('\\t', '\t').replace('\\\\', '\\')
            if "_build" in unescaped:
                code_blocks.append(unescaped)
                
        matches_triple = re.findall(r'"ReplacementContent"\s*:\s*"""(.*?)"""', content, re.DOTALL)
        for m in matches_triple:
            if "_build" in m:
                code_blocks.append(m)
                
        safe_print(f"  Found {len(code_blocks)} Dart code candidates in ReplacementContent fields.")
        for idx, block in enumerate(code_blocks):
            safe_print(f"  Block {idx} size: {len(block)} chars. First 100 chars: {block[:100].replace('\n', ' ')}")
            
    safe_print("-" * 60)
