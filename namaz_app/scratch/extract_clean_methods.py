import os
import re

reconstructed_file = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\reconstructed_tool_detail_screen.dart"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\clean_methods"
os.makedirs(output_dir, exist_ok=True)

with open(reconstructed_file, "r", encoding="utf-8") as f:
    content = f.read()

keywords = {
    "AylikNamazVakitleri": "_buildAylikNamazVakitleri",
    "Zikirmatik": "_buildZikirmatik",
    "KuranKerim": "_buildKuranKerim",
    "GunlukDualar": "_buildGunlukDualar",
    "DiniHoca": "_buildDiniHoca",
    "KibleBulucu": "_buildKibleBulucu",
    "WeekViewChart": "_buildWeekViewChart",
    "MonthlyCalendarView": "_buildMonthlyCalendarView"
}

def extract_method(pattern, full_text):
    # Regex to match method signature
    # e.g., Widget _buildAylikNamazVakitleri() {
    # Let's search for the pattern
    # We want to find the latest occurrence since it's the latest version in the reconstructed logs!
    matches = list(re.finditer(r'(?:Widget\s+)?' + pattern + r'\s*\([^)]*\)\s*\{', full_text))
    if not matches:
        return None
        
    # We take the last match (chronologically latest in logs)
    match = matches[-1]
    start_idx = match.start()
    
    brace_count = 0
    end_idx = start_idx
    started = False
    for i in range(start_idx, len(full_text)):
        char = full_text[i]
        if char == '{':
            brace_count += 1
            started = True
        elif char == '}':
            brace_count -= 1
        if started and brace_count == 0:
            end_idx = i + 1
            break
            
    if end_idx > start_idx:
        return full_text[start_idx:end_idx]
    return None

for name, pat in keywords.items():
    code = extract_method(pat, content)
    if code:
        out_path = os.path.join(output_dir, f"{name}.dart")
        with open(out_path, "w", encoding="utf-8") as out:
            out.write(code)
        print(f"Extracted {name} ({len(code)} chars) -> {out_path}")
    else:
        print(f"WARNING: Could not extract {name}")
