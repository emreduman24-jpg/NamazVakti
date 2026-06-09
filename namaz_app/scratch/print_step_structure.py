import json

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\843361bf-1546-40fc-89a6-3009c3ea3406\.system_generated\logs\transcript.jsonl"

with open(log_path, 'r', encoding='utf-8') as f:
    count = 0
    for line in f:
        try:
            data = json.loads(line)
            # Find a step where tool_calls are present
            if "tool_calls" in data and data["tool_calls"]:
                print(f"Step {data.get('step_index')}: Type: {data.get('type')}, Status: {data.get('status')}")
                print(json.dumps(data["tool_calls"][0], indent=2, ensure_ascii=False)[:500])
                print("-" * 50)
                count += 1
                if count >= 3:
                    break
        except Exception as e:
            print("Error parsing line:", e)
