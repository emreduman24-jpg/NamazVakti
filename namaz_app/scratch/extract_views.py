import json
import re

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"

with open(log_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if "main_screen.dart" in line:
            try:
                data = json.loads(line)
                
                # Check if it is a tool output of view_file
                if data.get("type") == "VIEW_FILE" or "view_file" in line:
                    content = data.get("content", "")
                    if "Showing lines" in content:
                        print(f"Step {data.get('step_index')}: {content[:100]}...")
                    # Also look in tool results or step content
                    tool_calls = data.get("tool_calls", [])
                    for tc in tool_calls:
                        if tc.get("name") == "view_file":
                            args = tc.get("args", {})
                            if isinstance(args, str):
                                args = json.loads(args)
                            print(f"  Call view_file args: {args}")
            except Exception as e:
                pass
