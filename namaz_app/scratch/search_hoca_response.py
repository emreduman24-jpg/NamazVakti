import os
import json

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_file = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\hoca_response_extracted.txt"

print("Searching transcript for _getDiniHocaResponse...")
matches = []

with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f):
        if "_getDiniHocaResponse" in line:
            matches.append(line_num)
            print(f"Match found at line {line_num}")

if matches:
    with open(output_file, "w", encoding="utf-8") as out:
        with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
            for line_num, line in enumerate(f):
                if line_num in matches:
                    out.write(f"\n--- Line {line_num} ---\n")
                    out.write(line[:2000] + "... TRUNCATED ...\n")
                    
                    # Try to parse and extract the tool call if it contains the full text
                    try:
                        obj = json.loads(line)
                        obj_str = json.dumps(obj, indent=2, ensure_ascii=False)
                        # Look for _getDiniHocaResponse definition in the JSON string
                        # Let's find index of _getDiniHocaResponse
                        idx = obj_str.find("_getDiniHocaResponse")
                        if idx != -1:
                            start = max(0, idx - 200)
                            end = min(len(obj_str), idx + 4000)
                            out.write("EXTRACTED PORTION:\n")
                            out.write(obj_str[start:end])
                            out.write("\n")
                    except Exception as e:
                        out.write(f"Parse error: {e}\n")
    print(f"Saved matches to {output_file}")
else:
    print("No matches found.")
