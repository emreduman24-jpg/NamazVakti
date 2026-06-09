import os
import json
import re

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_path = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\reconstructed_tool_detail_screen.dart"

line_map = {}
max_line = 0

print("Scanning transcript for file views...")

# Regex to match lines like "2750:             borderRadius: ... "
# Wait, some lines might be empty, like "2750: "
line_re = re.compile(r"^(\d+): (.*)$")

with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for step_num, line in enumerate(f):
        if "tool_detail_screen.dart" not in line:
            continue
        try:
            obj = json.loads(line)
        except:
            continue
            
        content = obj.get("content", "")
        if not content or "Showing lines" not in content:
            continue
            
        # Parse the content line by line
        lines = content.split("\n")
        for l in lines:
            m = line_re.match(l.strip())
            if m:
                line_num = int(m.group(1))
                line_content = m.group(2)
                line_map[line_num] = line_content
                if line_num > max_line:
                    max_line = line_num

print(f"Total unique lines reconstructed: {len(line_map)}")
print(f"Max line number: {max_line}")

if max_line > 0:
    # Write the stitched file
    with open(output_path, "w", encoding="utf-8") as out:
        for i in range(1, max_line + 1):
            # Fallback to empty string if a line is missing
            out.write(line_map.get(i, "") + "\n")
    print(f"Stitched file saved to {output_path}")
else:
    print("Failed to reconstruct file.")
