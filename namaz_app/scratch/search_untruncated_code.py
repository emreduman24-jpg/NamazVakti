import os
import re

dirs_to_search = [
    r"C:\Users\kral_\.gemini\antigravity\scratch",
    r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch"
]

keywords = {
    "AylikNamazVakitleri": "_buildAylikNamazVakitleri",
    "Zikirmatik": "_buildZikirmatik",
    "KuranKerim": "_buildKuranKerim",
    "GunlukDualar": "_buildGunlukDualar",
    "DiniHoca": "_buildDiniHoca",
    "KibleBulucu": "_buildKibleBulucu"
}

output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\recovered_clean_dart_v2"
os.makedirs(output_dir, exist_ok=True)

print("Starting deep search for clean code blocks...")

def clean_escaped_code(code_str):
    # If the code block contains JSON escapes, unescape it
    if '\\n' in code_str or '\\"' in code_str:
        code_str = code_str.replace('\\n', '\n')
        code_str = code_str.replace('\\"', '"')
        code_str = code_str.replace("\\'", "'")
        code_str = code_str.replace('\\t', '\t')
        code_str = code_str.replace('\\\\', '\\')
    return code_str

found_clean = {k: None for k in keywords}

for search_dir in dirs_to_search:
    if not os.path.exists(search_dir):
        continue
    for root, dirs, files in os.walk(search_dir):
        for file in files:
            if not file.endswith((".dart", ".txt", ".json", ".log")):
                continue
            filepath = os.path.join(root, file)
            try:
                with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
            except:
                continue
                
            for key, pattern in keywords.items():
                if pattern in content:
                    # Check if the file is a clean code file (does not contain log signatures)
                    is_log = "===================" in content or '"arguments"' in content or '"ReplacementContent"' in content
                    
                    if not is_log and filepath.endswith(".dart"):
                        # This is a clean Dart file! Let's extract the method
                        # Using regex to extract the method from Widget _buildXYZ() { to matching close brace
                        # But wait, it's easier to copy the whole file content or keep it as candidate
                        print(f"FOUND CLEAN DART FILE for {key}: {file} ({os.path.getsize(filepath)} bytes)")
                        if found_clean[key] is None or len(content) > len(found_clean[key][1]):
                            found_clean[key] = (filepath, content)
                    else:
                        # It is a log file. Let's see if we can parse out the code block of this method
                        # Let's search for the method definition inside the log
                        # It might be in ReplacementContent, or just written in text blocks
                        # Let's search for pattern starting with Widget _buildXYZ() { ... }
                        # Let's find all occurrences of Widget _buildXYZ() { and find matching braces
                        for match in re.finditer(r'(?:Widget\s+)?' + pattern + r'\s*\([^)]*\)\s*\{', content):
                            start_idx = match.start()
                            # Let's count braces to find matching close brace
                            brace_count = 0
                            end_idx = start_idx
                            started = False
                            for i in range(start_idx, len(content)):
                                char = content[i]
                                if char == '{':
                                    brace_count += 1
                                    started = True
                                elif char == '}':
                                    brace_count -= 1
                                if started and brace_count == 0:
                                    end_idx = i + 1
                                    break
                            if end_idx > start_idx:
                                extracted = content[start_idx:end_idx]
                                # Clean up escaped characters if it is from a log string
                                extracted = clean_escaped_code(extracted)
                                if "truncated" not in extracted:
                                    print(f"Extracted clean code for {key} from {file} (Step Log), size {len(extracted)} chars")
                                    # If it's a good size (e.g. > 1000 chars for large methods), save it
                                    if found_clean[key] is None or len(extracted) > len(found_clean[key][1]):
                                        found_clean[key] = (filepath + f" (extracted step)", extracted)

# Save best candidates
for key, data in found_clean.items():
    if data:
        source, code = data
        out_path = os.path.join(output_dir, f"{key}.dart")
        with open(out_path, "w", encoding="utf-8") as out:
            out.write(code)
        print(f"Saved best clean code for {key} to {out_path} (Source: {source})")
    else:
        print(f"WARNING: No clean code found for {key}")
