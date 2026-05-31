import json

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
target_file_path = "lib/screens/main_screen.dart"

restored = False
with open(log_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if "main_screen.dart" in line:
            try:
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
                                if code:
                                    # If the code string itself is a JSON-encoded string, decode it!
                                    if code.startswith('"') and code.endswith('"'):
                                        code = json.loads(code)
                                    else:
                                        # Also handle double escapes or raw escapes
                                        try:
                                            # Try decoding it as json string
                                            code = json.loads(f'"{code}"')
                                        except:
                                            pass
                                            
                                    # Just to be extremely sure about unescaping:
                                    if isinstance(code, str) and '\\n' in code:
                                        code = code.replace('\\n', '\n').replace('\\t', '\t').replace('\\"', '"').replace('\\\\', '\\')
                                        if code.startswith('"') and code.endswith('"'):
                                            code = code[1:-1]
                                            
                                    with open(target_file_path, "w", encoding="utf-8") as out:
                                        out.write(code)
                                    restored = True
                                    print(f"Restored and unescaped from line {i+1}!")
            except Exception as e:
                pass

if restored:
    print("SUCCESS")
else:
    print("FAILED")
