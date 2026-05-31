import json

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
line_num = 5929

with open(log_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if i + 1 == line_num:
            data = json.loads(line)
            print(f"Step Index: {data.get('step_index')}")
            print(f"Type: {data.get('type')}")
            content = data.get("content", "")
            print(f"Content Length: {len(content)}")
            # Print content around void _updateCountdown
            idx = content.find("void _updateCountdown")
            if idx != -1:
                print(content[idx:idx+2500])
            else:
                print("void _updateCountdown not found in content!")
                print(content[:2000])
            break
