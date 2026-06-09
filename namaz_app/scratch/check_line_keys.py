import os
import json

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"

target_lines = [16609, 16635]

with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f):
        if line_num not in target_lines:
            continue
            
        print(f"\n--- Line {line_num} ---")
        try:
            obj = json.loads(line)
            for k, v in obj.items():
                if isinstance(v, str):
                    print(f"Key '{k}': string value of length {len(v)} (Starts with: {v[:80]}...)")
                elif isinstance(v, list):
                    print(f"Key '{k}': list value of length {len(v)}")
                    for idx, item in enumerate(v):
                        print(f"  Item {idx}: type {type(item)}, keys: {list(item.keys()) if hasattr(item, 'keys') else 'N/A'}")
                else:
                    print(f"Key '{k}': value of type {type(v)}")
        except Exception as e:
            print(f"Error: {e}")
