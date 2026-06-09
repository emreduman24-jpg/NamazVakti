import json
import re
import os

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_tool_edits"

os.makedirs(output_dir, exist_ok=True)

print("Starting extraction of tool_detail_screen.dart modifications...")

with open(log_path, "r", encoding="utf-8") as f:
    for idx, line in enumerate(f):
        try:
            data = json.loads(line)
            step_idx = data.get("step_index", idx)
            tool_calls = data.get("tool_calls", [])
            
            for call_idx, call in enumerate(tool_calls):
                tool_name = call.get("name")
                args = call.get("args", {})
                
                # Check for write_to_file, replace_file_content, multi_replace_file_content
                target_file = args.get("TargetFile", "")
                if "tool_detail_screen.dart" in target_file:
                    print(f"Match found in step {step_idx}, tool call {tool_name}")
                    
                    # Dump this tool call details
                    out_filename = f"step_{step_idx}_{call_idx}_{tool_name}.json"
                    out_path = os.path.join(output_dir, out_filename)
                    with open(out_path, "w", encoding="utf-8") as out:
                        json.dump({
                            "step_index": step_idx,
                            "tool_name": tool_name,
                            "arguments": args
                        }, out, indent=2, ensure_ascii=False)
                        
        except Exception as e:
            pass

print("Extraction completed! Files written to:", output_dir)
