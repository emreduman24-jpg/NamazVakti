import json
import os

brain_path = r"C:\Users\kral_\.gemini\antigravity\brain"

log_files = []
for root, dirs, files in os.walk(brain_path):
    for f in files:
        if f == "transcript.jsonl":
            log_files.append(os.path.join(root, f))

print(f"Searching write_to_file in {len(log_files)} files...")

for log_file in log_files:
    try:
        with open(log_file, "r", encoding="utf-8") as f:
            for i, line in enumerate(f):
                if "write_to_file" in line and "main_screen.dart" in line:
                    print(f"Match in {log_file} line {i+1}!")
                    # Check if it has a write_to_file call
                    data = json.loads(line)
                    if "tool_calls" in data:
                        for tc in data["tool_calls"]:
                            if tc.get("name") == "write_to_file":
                                args = tc.get("args", {})
                                if isinstance(args, str):
                                    args = json.loads(args)
                                target_file = args.get("TargetFile", "")
                                if "main_screen.dart" in target_file:
                                    code = args.get("CodeContent", "")
                                    print(f"  Length: {len(code)}")
    except Exception as e:
        pass
