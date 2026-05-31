import json

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
line_num = 5929

with open(log_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if i + 1 == line_num:
            data = json.loads(line)
            for k, v in data.items():
                if k != "content":
                    print(f"{k}: {repr(v)[:500]}")
                else:
                    print(f"content length: {len(v)}")
            # If there are tool_calls, print them!
            if "tool_calls" in data:
                print("tool_calls:", repr(data["tool_calls"]))
            break
