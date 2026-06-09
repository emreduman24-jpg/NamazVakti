import json
import re
import os

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_view_contents"
os.makedirs(output_dir, exist_ok=True)

print("Searching for system responses containing tool_detail_screen.dart view contents...")

with open(log_path, "r", encoding="utf-8") as f:
    for idx, line in enumerate(f):
        # We look for steps containing tool_detail_screen.dart and showing lines
        if "tool_detail_screen.dart" not in line or "Showing lines" not in line:
            continue
            
        try:
            data = json.loads(line)
            step_index = data.get("step_index", idx)
            content = data.get("content", "")
            
            if "Showing lines" in content and "tool_detail_screen.dart" in content:
                print(f"Found view content at step {step_index}")
                
                # Extract the line range from content
                range_match = re.search(r"Showing lines (\d+) to (\d+)", content)
                range_str = ""
                if range_match:
                    range_str = f"lines_{range_match.group(1)}_to_{range_match.group(2)}"
                else:
                    range_str = "lines_all"
                    
                out_filename = f"step_{step_index}_{range_str}.txt"
                out_path = os.path.join(output_dir, out_filename)
                with open(out_path, "w", encoding="utf-8") as out:
                    out.write(content)
                print(f"  Saved to {out_filename} ({len(content)} chars)")
                
        except Exception as e:
            pass

print("Search completed!")
