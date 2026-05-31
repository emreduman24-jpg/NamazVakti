import json

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"

with open(log_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if "main_screen.dart" in line and ("Showing lines" in line or "File Path" in line):
            try:
                data = json.loads(line)
                step = data.get("step_index", i)
                content = data.get("content", "")
                print(f"Log Line {i+1} / Step {step}: has view content of size {len(content)}")
            except:
                pass
