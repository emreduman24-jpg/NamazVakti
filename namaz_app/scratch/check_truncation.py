import os
import json

edits_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_tool_edits"
files = os.listdir(edits_dir)

keywords = [
    "_buildKuranKerim",
    "_buildZikirmatik",
    "_buildGunlukDualar",
    "_buildDiniHoca",
    "_buildAylikNamazVakitleri",
    "_buildKibleBulucu"
]

print("Checking JSON edits for truncation status...")

for filename in files:
    if not filename.endswith(".json"):
        continue
        
    filepath = os.path.join(edits_dir, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
            step_idx = data.get("step_index")
            args = data.get("arguments", {})
            
            # Stringify arguments to check size and truncation
            args_str = json.dumps(args, ensure_ascii=False)
            
            # Check if it contains any of the methods
            found_kws = [kw for kw in keywords if kw in args_str]
            if not found_kws:
                continue
                
            is_truncated = "truncated" in args_str
            size = len(args_str)
            
            print(f"Step {step_idx} ({filename}): Size={size} chars, Keywords={found_kws}, Truncated={is_truncated}")
            
        except Exception as e:
            pass
