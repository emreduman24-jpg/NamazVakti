import os
import json

views_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_views"

# Get all files and sort by step index
files = [f for f in os.listdir(views_dir) if f.endswith(".json")]
def get_step_idx(filename):
    return int(filename.split("_")[1])
files.sort(key=get_step_idx, reverse=True)

print("Top 10 latest view steps:")
for f in files[:10]:
    filepath = os.path.join(views_dir, f)
    with open(filepath, "r", encoding="utf-8") as file:
        data = json.load(file)
        # Check if this step has output/content and its size
        content = data.get("content", "")
        # If it's a model response, the tool output might be in the system's message in transcript
        # Let's print some info
        print(f"File: {f}, Content length: {len(content)} characters")
        if content:
            print("  First 100 chars:", content[:100].replace('\n', ' '))
