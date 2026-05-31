import json
import re

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"

lines_dict = {}

with open(log_path, "r", encoding="utf-8") as f:
    for step_num, line in enumerate(f):
        if "main_screen.dart" in line:
            try:
                data = json.loads(line)
                
                # Check for step results or content of type VIEW_FILE or SYSTEM messages containing view file output
                content = data.get("content", "")
                if "File Path:" in content and "main_screen.dart" in content:
                    # Find all lines in format "123: line content"
                    # We can use regex to find "<line_num>: <content>"
                    matches = re.findall(r"^(\d+): (.*)$", content, re.MULTILINE)
                    for num_str, text in matches:
                        num = int(num_str)
                        lines_dict[num] = text
            except Exception as e:
                pass

print(f"Reconstructed {len(lines_dict)} lines of main_screen.dart!")
if lines_dict:
    max_line = max(lines_dict.keys())
    print(f"Max line number: {max_line}")
    
    # Check if there are any missing lines up to max_line
    missing = []
    for i in range(1, max_line + 1):
        if i not in lines_dict:
            missing.append(i)
    print(f"Missing lines: {len(missing)} out of {max_line}")
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
        
        # Save whatever we have to a temporary file to see it
        with open("scratch/reconstructed_main_partial.dart", "w", encoding="utf-8") as out:
            for i in range(1, max_line + 1):
                out.write(f"{i}: {lines_dict.get(i, 'MISSING')}\n")
    else:
        # We have all lines! Save it!
        with open("lib/screens/main_screen.dart", "w", encoding="utf-8") as out:
            for i in range(1, max_line + 1):
                out.write(f"{lines_dict[i]}\n")
        print("SUCCESSFULLY RECONSTRUCTED AND SAVED THE ENTIRE FILE!")
else:
    print("No lines found to reconstruct.")
