import json

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\843361bf-1546-40fc-89a6-3009c3ea3406\.system_generated\logs\transcript.jsonl"
steps_to_find = [1071, 1143, 1306]

with open(log_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            step_idx = data.get("step_index")
            if step_idx in steps_to_find:
                out_path = f"c:\\Users\\kral_\\Namaz vakitleri\\namaz_app\\scratch\\step_dump_{step_idx}.json"
                with open(out_path, 'w', encoding='utf-8') as out_f:
                    json.dump(data, out_f, indent=2, ensure_ascii=False)
                print(f"Dumped step {step_idx} to {out_path}")
        except Exception as e:
            continue
