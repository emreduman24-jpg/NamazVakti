import json
import re
import os

convs = ["843361bf-1546-40fc-89a6-3009c3ea3406", "bfa70658-74aa-43c5-b71d-b66952b42f2e"]

for conv in convs:
    log_path = f"C:\\Users\\kral_\\.gemini\\antigravity\\brain\\{conv}\\.system_generated\\logs\\transcript.jsonl"
    if not os.path.exists(log_path):
        continue
    print(f"Scanning conversation {conv}...")
    
    with open(log_path, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f, 1):
            try:
                data = json.loads(line)
            except:
                continue
                
            content = data.get("content", "")
            step_index = data.get("step_index")
            source = data.get("source")
            
            # Look for markdown code blocks
            code_blocks = re.findall(r"```dart\s*(.*?)\s*```", content, re.DOTALL)
            for idx, block in enumerate(code_blocks):
                lines = block.split('\n')
                first_lines = "\n".join(lines[:3])
                print(f"Step {step_index} (Source: {source}) Code Block {idx}: {len(block)} chars, {len(lines)} lines")
                print(f"First 3 lines:\n{first_lines}")
                print("-" * 30)
