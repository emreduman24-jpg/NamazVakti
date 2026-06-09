import os
import json

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_file = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\dini_hoca_full_extracted.dart"

target_lines = [16609, 16635]

with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f):
        if line_num not in target_lines:
            continue
            
        print(f"Processing line {line_num}...")
        try:
            obj = json.loads(line)
        except Exception as e:
            print(f"Error parsing JSON: {e}")
            continue
            
        # Extract ReplacementContent from tool_calls
        tool_calls = obj.get("tool_calls", [])
        if not tool_calls:
            # Check content
            content = obj.get("content", "")
            if content:
                with open(output_file.replace(".dart", f"_line_{line_num}.txt"), "w", encoding="utf-8") as out:
                    out.write(content)
                print(f"Saved content to {output_file.replace('.dart', f'_line_{line_num}.txt')}")
            continue
            
        for idx, tc in enumerate(tool_calls):
            args = tc.get("args", {})
            repl = args.get("ReplacementContent", "")
            if repl:
                fn = output_file.replace(".dart", f"_line_{line_num}_call_{idx}.dart")
                with open(fn, "w", encoding="utf-8") as out:
                    out.write(repl)
                print(f"Saved ReplacementContent to {fn} ({len(repl)} chars)")
