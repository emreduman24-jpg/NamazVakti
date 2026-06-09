import os
import json
import re

transcript_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\recovered_from_transcript"
os.makedirs(output_dir, exist_ok=True)

keywords = {
    "AylikNamazVakitleri": "_buildAylikNamazVakitleri",
    "Zikirmatik": "_buildZikirmatik",
    "KuranKerim": "_buildKuranKerim",
    "GunlukDualar": "_buildGunlukDualar",
    "DiniHoca": "_buildDiniHoca",
    "KibleBulucu": "_buildKibleBulucu"
}

def clean_escaped_code(code_str):
    if '\\n' in code_str or '\\"' in code_str:
        code_str = code_str.replace('\\n', '\n')
        code_str = code_str.replace('\\"', '"')
        code_str = code_str.replace("\\'", "'")
        code_str = code_str.replace('\\t', '\t')
        code_str = code_str.replace('\\\\', '\\')
    return code_str

found_blocks = {k: [] for k in keywords}

print(f"Reading transcript from {transcript_path}...")
with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f):
        if not any(pat in line for pat in keywords.values()):
            continue
        
        try:
            obj = json.loads(line)
        except Exception as e:
            # Try parsing manually if it's not valid json
            continue
            
        # We search inside obj for tool_calls, or content, or tool responses
        obj_str = json.dumps(obj)
        
        for key, pattern in keywords.items():
            # Check for the pattern inside the json string
            for match in re.finditer(r'(?:Widget\s+)?' + pattern + r'\s*\([^)]*\)\s*\{', obj_str):
                start_idx = match.start()
                brace_count = 0
                end_idx = start_idx
                started = False
                for i in range(start_idx, len(obj_str)):
                    char = obj_str[i]
                    if char == '{':
                        brace_count += 1
                        started = True
                    elif char == '}':
                        brace_count -= 1
                    if started and brace_count == 0:
                        end_idx = i + 1
                        break
                if end_idx > start_idx:
                    extracted = obj_str[start_idx:end_idx]
                    extracted = clean_escaped_code(extracted)
                    if "truncated" not in extracted:
                        found_blocks[key].append((line_num, len(extracted), extracted))

# Write out the results
for key, list_of_blocks in found_blocks.items():
    if not list_of_blocks:
        print(f"No untruncated blocks found for {key}")
        continue
    # Sort by length, descending
    list_of_blocks.sort(key=lambda x: x[1], reverse=True)
    best_line, best_len, best_code = list_of_blocks[0]
    print(f"Best block for {key}: line {best_line}, length {best_len} chars")
    
    out_path = os.path.join(output_dir, f"{key}.dart")
    with open(out_path, "w", encoding="utf-8") as out_f:
        out_f.write(best_code)
    print(f"Saved to {out_path}")
