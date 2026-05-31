import json
import re

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
target_file_path = "lib/screens/main_screen.dart"

lines_dict = {}

# We will read transcript.jsonl
with open(log_path, "r", encoding="utf-8") as f:
    for line in f:
        try:
            data = json.loads(line)
            
            # Check if this step is a tool execution result containing view_file of main_screen.dart
            content = data.get("content", "")
            if "File Path:" in content and "main_screen.dart" in content and "Showing lines" in content:
                # Extract line numbers
                matches = re.findall(r"^(\d+): (.*)$", content, re.MULTILINE)
                for num_str, text in matches:
                    num = int(num_str)
                    lines_dict[num] = text
        except Exception as e:
            pass

print(f"Perfect Reconstructed {len(lines_dict)} lines!")
if lines_dict:
    max_line = max(lines_dict.keys())
    print(f"Max line number: {max_line}")
    missing = [i for i in range(1, max_line + 1) if i not in lines_dict]
    print(f"Missing lines: {len(missing)}")
    if missing:
        # Group missing into ranges
        ranges = []
        start = missing[0]
        prev = missing[0]
        for m in missing[1:]:
            if m == prev + 1:
                prev = m
            else:
                ranges.append(f"{start}-{prev}")
                start = m
                prev = m
        ranges.append(f"{start}-{prev}")
        print(f"Missing ranges: {', '.join(ranges)}")
        
        # Write to temporary debug file
        with open("scratch/perfect_main_partial.dart", "w", encoding="utf-8") as out:
            for i in range(1, max_line + 1):
                out.write(f"{i}: {lines_dict.get(i, 'MISSING')}\n")
    else:
        with open(target_file_path, "w", encoding="utf-8") as out:
            for i in range(1, max_line + 1):
                out.write(f"{lines_dict[i]}\n")
        print("PERFECT SUCCESS!")
else:
    print("No lines found.")
