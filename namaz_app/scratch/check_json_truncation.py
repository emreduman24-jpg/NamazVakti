import os
import json

edits_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_tool_edits_full"
files = os.listdir(edits_dir)

print(f"Total edit files to inspect: {len(files)}")

for file in sorted(files):
    if not file.endswith(".json"):
        continue
    filepath = os.path.join(edits_dir, file)
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
        
    has_truncation = "truncated" in content or "TRUNCATED" in content
    
    # Try parsing JSON and check specific keys
    try:
        data = json.loads(content)
        inst = data.get("Instruction", "")
        desc = data.get("Description", "")
        # Let's print files that DO NOT contain truncation and seem to be full replacements
        if not has_truncation:
            print(f"[CLEAN] {file} - size {len(content)} - Inst: {inst[:60]}")
        else:
            print(f"[TRUNCATED] {file} - size {len(content)} - Inst: {inst[:60]}")
    except Exception as e:
        print(f"[PARSE ERROR] {file}: {e}")
