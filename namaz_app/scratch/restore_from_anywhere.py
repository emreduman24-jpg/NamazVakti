import json
import os

brain_path = r"C:\Users\kral_\.gemini\antigravity\brain"
target_file_path = "lib/screens/main_screen.dart"

log_files = []
for root, dirs, files in os.walk(brain_path):
    for f in files:
        if f == "transcript.jsonl":
            log_files.append(os.path.join(root, f))

print(f"Found {len(log_files)} log files using os.walk!")

best_code = ""
best_log = ""

for log_file in log_files:
    try:
        with open(log_file, "r", encoding="utf-8") as f:
            for line in f:
                if "write_to_file" in line and "main_screen.dart" in line:
                    data = json.loads(line)
                    if "tool_calls" in data:
                        for tc in data["tool_calls"]:
                            if tc.get("name") == "write_to_file":
                                args = tc.get("args", {})
                                if isinstance(args, str):
                                    args = json.loads(args)
                                if "main_screen.dart" in args.get("TargetFile", ""):
                                    code = args.get("CodeContent", "")
                                    # Look for the complete long code
                                    if len(code) > len(best_code):
                                        best_code = code
                                        best_log = log_file
    except Exception as e:
        pass

if best_code:
    # If the code string itself is a JSON-encoded string, decode it!
    if best_code.startswith('"') and best_code.endswith('"'):
        best_code = json.loads(best_code)
    else:
        try:
            best_code = json.loads(f'"{best_code}"')
        except:
            pass
            
    if isinstance(best_code, str) and '\\n' in best_code:
        best_code = best_code.replace('\\n', '\n').replace('\\t', '\t').replace('\\"', '"').replace('\\\\', '\\')
        if best_code.startswith('"') and best_code.endswith('"'):
            best_code = best_code[1:-1]
            
    with open(target_file_path, "w", encoding="utf-8") as out:
        out.write(best_code)
    print(f"SUCCESS! Restored code of length {len(best_code)} from {best_log}")
else:
    print("FAILED")
