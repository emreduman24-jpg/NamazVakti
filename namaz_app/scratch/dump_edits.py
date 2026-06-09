import os
import json

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_tool_edits_full"
os.makedirs(output_dir, exist_ok=True)

print(f"Scanning transcript for edits to tool_detail_screen.dart...")

with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f):
        if "replace_file_content" not in line and "multi_replace_file_content" not in line:
            continue
        try:
            obj = json.loads(line)
        except:
            continue
            
        # We need the model's request where it specifies tool calls
        if obj.get("source") != "MODEL" or "tool_calls" not in obj:
            continue
            
        tool_calls = obj["tool_calls"]
        for idx, tc in enumerate(tool_calls):
            t_name = tc.get("name", "")
            if t_name not in ["replace_file_content", "multi_replace_file_content"]:
                continue
                
            args = tc.get("args", {})
            target_file = args.get("TargetFile", "")
            if "tool_detail_screen.dart" not in target_file:
                continue
                
            # Found one! Let's write it to a file
            step_index = obj.get("step_index", line_num)
            out_filename = f"step_{step_index}_{idx}_{t_name}.json"
            out_path = os.path.join(output_dir, out_filename)
            
            with open(out_path, "w", encoding="utf-8") as out_f:
                json.dump(args, out_f, indent=2, ensure_ascii=False)
                
            print(f"Extracted edit at step {step_index}: {out_filename} (Instruction: {args.get('Instruction', '')[:50]}...)")
