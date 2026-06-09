import os
import json

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_file = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\hoca_body_extracted.txt"

print("Searching transcript for Dini Hoca response method definition...")

# We search for any line in transcript that contains the body of _getDiniHocaResponse
# For example, searching for keywords in the Dini Hoca replies: "Abdest", "Gusül", "Namaz", "Zekat"
with open(output_file, "w", encoding="utf-8") as out:
    with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
        for line_num, line in enumerate(f):
            if "String _getDiniHocaResponse" in line or "Diyanet İşleri Başkanlığı'nın resmi fetvalarına" in line:
                print(f"Match found at line {line_num}")
                try:
                    obj = json.loads(line)
                    content = obj.get("content", "")
                    if content:
                        out.write(f"\n--- Line {line_num} (VIEW_FILE Content) ---\n")
                        out.write(content)
                        out.write("\n")
                    else:
                        # Maybe it is in tool_calls arguments
                        for tc in obj.get("tool_calls", []):
                            repl = tc.get("args", {}).get("ReplacementContent", "")
                            if repl:
                                out.write(f"\n--- Line {line_num} (ReplacementContent) ---\n")
                                out.write(repl)
                                out.write("\n")
                except Exception as e:
                    out.write(f"Error parsing line {line_num}: {e}\n")

print("Finished search.")
