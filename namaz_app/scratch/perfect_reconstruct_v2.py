import json
import re

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
target_file_path = "lib/screens/main_screen.dart"

lines_dict = {}

with open(log_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if "main_screen.dart" in line and "Showing lines" in line:
            try:
                data = json.loads(line)
                content = data.get("content", "")
                
                # Check that this content is indeed the file view output of main_screen.dart
                # Match path ending in main_screen.dart or main_screen.dart#L...
                path_match = re.search(r"File Path:\s*`?file:///.*main_screen\.dart`?", content, re.IGNORECASE)
                if path_match:
                    matches = re.findall(r"^(\d+): (.*)$", content, re.MULTILINE)
                    for num_str, text in matches:
                        num = int(num_str)
                        lines_dict[num] = text
            except Exception as e:
                pass

print(f"Robust Reconstructed {len(lines_dict)} lines!")
if lines_dict:
    max_line = max(lines_dict.keys())
    print(f"Max line number: {max_line}")
    missing = [i for i in range(1, max_line + 1) if i not in lines_dict]
    print(f"Missing lines: {len(missing)}")
    if missing:
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
        
        with open("scratch/perfect_main_partial_v3.dart", "w", encoding="utf-8") as out:
            for i in range(1, max_line + 1):
                out.write(f"{i}: {lines_dict.get(i, 'MISSING')}\n")
    else:
        with open(target_file_path, "w", encoding="utf-8") as out:
            for i in range(1, max_line + 1):
                out.write(f"{lines_dict[i]}\n")
        print("PERFECT V3 SUCCESS!")
else:
    print("No lines found.")
