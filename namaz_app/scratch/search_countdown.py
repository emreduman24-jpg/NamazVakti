import json
import os

brain_path = r"C:\Users\kral_\.gemini\antigravity\brain"

log_files = []
for root, dirs, files in os.walk(brain_path):
    for f in files:
        if f == "transcript.jsonl":
            log_files.append(os.path.join(root, f))

print(f"Searching _updateCountdown in {len(log_files)} files...")

for log_file in log_files:
    try:
        with open(log_file, "r", encoding="utf-8") as f:
            for i, line in enumerate(f):
                if "_updateCountdown" in line and "void _updateCountdown" in line:
                    print(f"Match in {log_file} line {i+1}!")
                    # Check if it is a write_to_file or a view_file result
                    data = json.loads(line)
                    content = data.get("content", "")
                    if "void _updateCountdown" in content:
                        print(f"  Content length: {len(content)}")
                        # Print surrounding text of the match
                        idx = content.find("void _updateCountdown")
                        print(content[idx:idx+1500])
                        print("====================================")
    except Exception as e:
        pass
