import os
import json

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\hoca_untruncated"
os.makedirs(output_dir, exist_ok=True)

target_lines = [16530, 16608, 16657, 16659, 16660]

with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f):
        if line_num not in target_lines:
            continue
            
        print(f"Reading line {line_num}...")
        try:
            obj = json.loads(line)
        except Exception as e:
            print(f"Error parsing line {line_num}: {e}")
            continue
            
        tool_calls = obj.get("tool_calls", [])
        for idx, tc in enumerate(tool_calls):
            args = tc.get("args", {})
            repl = args.get("ReplacementContent", "")
            if repl:
                fn = os.path.join(output_dir, f"line_{line_num}_call_{idx}.dart")
                with open(fn, "w", encoding="utf-8") as out:
                    out.write(repl)
                print(f"Saved {len(repl)} chars to {fn}")
            else:
                # E.g. in multi_replace_file_content
                chunks = args.get("ReplacementChunks", [])
                for c_idx, chunk in enumerate(chunks):
                    chunk_repl = chunk.get("ReplacementContent", "")
                    if chunk_repl:
                        fn = os.path.join(output_dir, f"line_{line_num}_multi_{idx}_chunk_{c_idx}.dart")
                        with open(fn, "w", encoding="utf-8") as out:
                            out.write(chunk_repl)
                        print(f"Saved multi chunk {len(chunk_repl)} chars to {fn}")
