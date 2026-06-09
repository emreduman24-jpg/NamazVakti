import os
import json
import re

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"
files = os.listdir(scratch_dir)

target_prefixes = [
    "extracted_buildZikirmatik_",
    "extracted_buildKuranKerim_",
    "extracted_buildDiniHoca_",
    "extracted_buildSoruCevap_",
    "extracted_buildWeekViewChart_",
    "extracted_monthly_"
]

keywords = [
    "_buildZikirmatik",
    "_buildKuranKerim",
    "_buildGunlukDualar",
    "_buildDiniHoca",
    "_buildAylikNamazVakitleri",
    "_buildKibleBulucu",
    "_buildWeekViewChart"
]

print("Scanning extracted log files in root scratch...")

for prefix in target_prefixes:
    matching_files = [f for f in files if f.startswith(prefix)]
    print(f"\nPrefix: {prefix} ({len(matching_files)} files)")
    
    # Sort files by their index
    def get_index(f):
        m = re.search(r'_(\d+)\.dart$', f)
        return int(m.group(1)) if m else 0
        
    matching_files.sort(key=get_index)
    
    for f in matching_files:
        filepath = os.path.join(scratch_dir, f)
        size = os.path.getsize(filepath)
        
        with open(filepath, "r", encoding="utf-8", errors="ignore") as file:
            content = file.read()
            
        # Check if there is a tool call in it
        # Step logs are saved as raw text or JSON
        # Let's see if it contains replacement content or target content
        has_rep = "ReplacementContent" in content
        found_kws = [kw for kw in keywords if kw in content]
        
        if len(found_kws) > 0:
            print(f"  File: {f} (Size: {size} bytes) | Keywords: {found_kws} | Has ReplacementContent: {has_rep}")
            # If it has ReplacementContent, print a snippet
            if has_rep:
                # Find where ReplacementContent is and print a short snippet
                rep_match = re.search(r'"ReplacementContent"\s*:\s*"(.*?)"', content, re.DOTALL)
                if rep_match:
                    rep_text = rep_match.group(1)[:100].replace('\\n', ' ')
                    print(f"    Snippet: {rep_text}")
                else:
                    print("    (ReplacementContent pattern not matched)")
