import json
import os

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\843361bf-1546-40fc-89a6-3009c3ea3406\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_steps"
os.makedirs(output_dir, exist_ok=True)

print("Starting extraction of code changes from transcript...")

with open(log_path, 'r', encoding='utf-8') as f:
    for line_num, line in enumerate(f, 1):
        try:
            data = json.loads(line)
        except Exception as e:
            continue
            
        step_index = data.get("step_index")
        tool_calls = data.get("tool_calls", [])
        
        # Check if the model called a write/replace tool
        for call_idx, call in enumerate(tool_calls):
            name = call.get("name", "")
            args = call.get("arguments", {})
            if not isinstance(args, dict):
                try:
                    args = json.loads(args)
                except:
                    continue
            
            target_file = args.get("TargetFile", "")
            content_written = ""
            
            if "tool_detail_screen.dart" in target_file:
                if name == "replace_file_content":
                    content_written = args.get("ReplacementContent", "")
                elif name == "multi_replace_file_content":
                    chunks = args.get("ReplacementChunks", [])
                    if isinstance(chunks, list):
                        content_written = "\n=== CHUNK ===\n".join([c.get("ReplacementContent", "") for c in chunks if isinstance(c, dict)])
                elif name == "write_to_file":
                    content_written = args.get("CodeContent", "")
                    
            if content_written:
                out_path = os.path.join(output_dir, f"step_{step_index}_{call_idx}.json")
                with open(out_path, 'w', encoding='utf-8') as out_f:
                    json.dump({
                        "step_index": step_index,
                        "tool": name,
                        "target": target_file,
                        "content": content_written
                    }, out_f, indent=2, ensure_ascii=False)
                print(f"Extracted step {step_index} call {call_idx} to {out_path} ({len(content_written)} chars)")
