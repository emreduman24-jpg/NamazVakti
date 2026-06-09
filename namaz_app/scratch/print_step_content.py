import json

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\843361bf-1546-40fc-89a6-3009c3ea3406\.system_generated\logs\transcript.jsonl"
steps_to_find = [1071, 1143, 1306]

with open(log_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            if data.get("step_index") in steps_to_find:
                print(f"=== STEP {data.get('step_index')} ===")
                print(data.get("content")[:1500])
                print("..." if len(data.get("content", "")) > 1500 else "")
                print("-" * 50)
        except Exception as e:
            continue
