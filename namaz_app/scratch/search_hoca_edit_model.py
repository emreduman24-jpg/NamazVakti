import os
import json

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_file = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\hoca_edit_model_extracted.txt"

print("Searching transcript for MODEL tool calls matching Dini Hoca...")
matches = []

with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f):
        if '"source":"MODEL"' in line and ("_buildDiniHoca" in line or "Dini Hoca" in line or "_getDiniHocaResponse" in line):
            if "replace_file_content" in line or "multi_replace_file_content" in line:
                matches.append(line_num)
                print(f"MODEL edit call found at line {line_num}")

if matches:
    with open(output_file, "w", encoding="utf-8") as out:
        with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
            for line_num, line in enumerate(f):
                if line_num in matches:
                    out.write(f"\n--- Line {line_num} (MODEL Tool Call) ---\n")
                    try:
                        obj = json.loads(line)
                        tool_calls = obj.get("tool_calls", [])
                        for idx, tc in enumerate(tool_calls):
                            args = tc.get("args", {})
                            repl = args.get("ReplacementContent", "")
                            if repl:
                                out.write(f"REPLACEMENT CONTENT FOR CALL {idx} ({len(repl)} chars):\n")
                                out.write(repl)
                                out.write("\n")
                            else:
                                out.write(f"Call {idx} args: {json.dumps(args, indent=2, ensure_ascii=False)[:1000]}...\n")
                    except Exception as e:
                        out.write(f"Error parsing JSON: {e}\n")
    print(f"Saved results to {output_file}")
else:
    print("No MODEL edit calls found.")
