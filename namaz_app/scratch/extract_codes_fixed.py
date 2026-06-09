import json
import os

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\843361bf-1546-40fc-89a6-3009c3ea3406\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_steps"
os.makedirs(output_dir, exist_ok=True)

print("Starting extraction of code changes from transcript...")

def clean_val(val):
    if not isinstance(val, str):
        return val
    # Strip leading/trailing quotes and clean up escaped slashes
    val = val.strip()
    if val.startswith('"') and val.endswith('"'):
        val = val[1:-1]
    val = val.replace('\\\\', '\\')
    return val

with open(log_path, 'r', encoding='utf-8') as f:
    for line_num, line in enumerate(f, 1):
        try:
            data = json.loads(line)
        except Exception as e:
            continue
            
        step_index = data.get("step_index")
        tool_calls = data.get("tool_calls", [])
        
        for call_idx, call in enumerate(tool_calls):
            name = call.get("name", "")
            args = call.get("args", {})
            if not isinstance(args, dict):
                continue
            
            target_file = clean_val(args.get("TargetFile", ""))
            content_written = ""
            
            if "tool_detail_screen.dart" in target_file:
                if name == "replace_file_content":
                    content_written = clean_val(args.get("ReplacementContent", ""))
                elif name == "multi_replace_file_content":
                    chunks = args.get("ReplacementChunks", "")
                    if isinstance(chunks, str):
                        # Some logs have chunks as a JSON string
                        try:
                            chunks = json.loads(clean_val(chunks))
                        except Exception as e:
                            print(f"Error parsing chunks string in step {step_index}: {e}")
                            chunks = []
                    if isinstance(chunks, list):
                        parts = []
                        for c in chunks:
                            if isinstance(c, dict):
                                parts.append(clean_val(c.get("ReplacementContent", "")))
                        content_written = "\n=== CHUNK ===\n".join(parts)
                elif name == "write_to_file":
                    content_written = clean_val(args.get("CodeContent", ""))
                    
            if content_written:
                out_path = os.path.join(output_dir, f"cur_step_{step_index}_{call_idx}.json")
                with open(out_path, 'w', encoding='utf-8') as out_f:
                    json.dump({
                        "step_index": step_index,
                        "tool": name,
                        "target": target_file,
                        "content": content_written
                    }, out_f, indent=2, ensure_ascii=False)
                print(f"Extracted step {step_index} call {call_idx} to {out_path} ({len(content_written)} chars)")
