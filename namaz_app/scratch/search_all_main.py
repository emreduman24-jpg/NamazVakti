import json
import os
import re

brain_path = r"C:\Users\kral_\.gemini\antigravity\brain"

log_files = []
for root, dirs, files in os.walk(brain_path):
    for f in files:
        if f == "transcript.jsonl":
            log_files.append(os.path.join(root, f))

print(f"Searching in {len(log_files)} log files...")

for log_file in log_files:
    try:
        found_lines = {}
        with open(log_file, "r", encoding="utf-8") as f:
            for i, line in enumerate(f):
                if "main_screen.dart" in line:
                    data = json.loads(line)
                    content = data.get("content", "")
                    if "File Path:" in content and "main_screen.dart" in content:
                        matches = re.findall(r"^(\d+): (.*)$", content, re.MULTILINE)
                        for num_str, text in matches:
                            num = int(num_str)
                            found_lines[num] = text
        if found_lines:
            print(f"File {log_file} has {len(found_lines)} unique lines of main_screen.dart.")
            # Print if it covers the missing ranges
            missing_ranges = [(130, 132), (391, 394), (661, 661), (873, 915)]
            covered = []
            for r in missing_ranges:
                all_in = True
                for num in range(r[0], r[1] + 1):
                    if num not in found_lines:
                        all_in = False
                        break
                if all_in:
                    covered.append(f"{r[0]}-{r[1]}")
            if covered:
                print(f"  --> Covers missing ranges: {', '.join(covered)}")
    except Exception as e:
        pass
