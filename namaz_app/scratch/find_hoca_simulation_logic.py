import json
import os

convs = ["843361bf-1546-40fc-89a6-3009c3ea3406", "bfa70658-74aa-43c5-b71d-b66952b42f2e"]

for conv in convs:
    log_path = f"C:\\Users\\kral_\\.gemini\\antigravity\\brain\\{conv}\\.system_generated\\logs\\transcript.jsonl"
    if not os.path.exists(log_path):
        continue
    
    with open(log_path, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f, 1):
            if "Abdest nasıl alınır?" in line:
                try:
                    data = json.loads(line)
                    content = data.get("content", "")
                    # Look for code blocks or strings that contain responses
                    if "cevap" in content or "reply" in content or "answer" in content:
                        print(f"Match in conv {conv[:8]} step {data.get('step_index')}:")
                        print(content[:600])
                        print("-" * 50)
                except:
                    continue
