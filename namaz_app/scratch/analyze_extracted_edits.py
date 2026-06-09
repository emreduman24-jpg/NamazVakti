import os
import json

edits_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_tool_edits"
files = os.listdir(edits_dir)

# Sort files by step index
def get_step_idx(filename):
    parts = filename.split("_")
    if len(parts) > 1:
        try:
            return int(parts[1])
        except ValueError:
            return 0
    return 0

files.sort(key=get_step_idx)

keywords = [
    "_buildZikirmatik",
    "_buildKuranKerim",
    "_buildGunlukDualar",
    "_buildDiniHoca",
    "_buildAylikNamazVakitleri",
    "_buildKibleBulucu"
]

results = {kw: [] for kw in keywords}

for filename in files:
    if not filename.endswith(".json"):
        continue
    filepath = os.path.join(edits_dir, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
            step_idx = data.get("step_index")
            tool_name = data.get("tool_name")
            args = data.get("arguments", {})
            
            # Stringify arguments to search keywords
            args_str = json.dumps(args, ensure_ascii=False)
            
            for kw in keywords:
                if kw in args_str:
                    results[kw].append({
                        "step": step_idx,
                        "file": filename,
                        "tool": tool_name
                    })
        except Exception as e:
            pass

print("=== Search Results ===")
for kw, matches in results.items():
    print(f"\nKeyword: {kw}")
    if not matches:
        print("  No matches.")
    else:
        # Print last 5 matches for brevity
        for m in matches[-5:]:
            print(f"  Step {m['step']}: {m['file']} ({m['tool']})")
