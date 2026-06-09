import json
import re
import os

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_views"
os.makedirs(output_dir, exist_ok=True)

print("Searching for view_file on tool_detail_screen.dart...")

with open(log_path, "r", encoding="utf-8") as f:
    for idx, line in enumerate(f):
        try:
            # Quick check to avoid parsing JSON if not relevant
            if "tool_detail_screen.dart" not in line or "view_file" not in line:
                continue
                
            data = json.loads(line)
            step_idx = data.get("step_index", idx)
            tool_calls = data.get("tool_calls", [])
            
            # Check if it is a view_file tool call
            is_view = False
            for call in tool_calls:
                if call.get("name") == "view_file":
                    args = call.get("args", {})
                    path = args.get("AbsolutePath", "")
                    if "tool_detail_screen.dart" in path:
                        is_view = True
                        break
            
            if is_view:
                # Get the response content
                # The response is usually in data.get("status") or in the next step, or in the same step depending on format.
                # In transcript.jsonl, the tool output is often in the same step under "content" or a subfield when status is DONE.
                print(f"Found view_file at step {step_idx}")
                out_path = os.path.join(output_dir, f"step_{step_idx}_view.json")
                with open(out_path, "w", encoding="utf-8") as out:
                    json.dump(data, out, indent=2, ensure_ascii=False)
                    
        except Exception as e:
            pass

print("Search completed! Files written to:", output_dir)
