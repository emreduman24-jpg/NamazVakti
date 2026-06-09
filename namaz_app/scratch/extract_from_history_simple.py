import os
import re

history_path = r"C:\Users\kral_\.gemini\antigravity\scratch\history_output_simple_utf8.txt"
output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\history_extracted"
os.makedirs(output_dir, exist_ok=True)

if not os.path.exists(history_path):
    print("History file not found.")
    exit(1)

with open(history_path, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# We can split the file by the step headers
# E.g. "=================== STEP XXX (tool_name) ==================="
steps = re.split(r"===================\s*STEP\s*(\d+)\s*\(([^)]+)\)\s*===================", content)

# steps list will be: [preamble, step_num_1, tool_1, content_1, step_num_2, tool_2, content_2, ...]
print(f"Total steps found in simple history: {len(steps) // 3}")

target_steps = {
    "Zikirmatik": [16032, 15998, 12961, 1654],
    "KuranKerim": [14873, 14863, 14620, 14614, 1654],
    "GunlukDualar": [16498, 16434, 1654],
    "DiniHoca": [16831, 16829, 16780, 16744],
    "AylikVakitler": [13044, 12961, 12955],
    "KibleBulucu": [12955, 12789, 1332]
}

# Map step number to its content
step_map = {}
for i in range(1, len(steps), 3):
    step_num = int(steps[i])
    tool = steps[i+1].strip()
    step_content = steps[i+2]
    step_map[step_num] = (tool, step_content)

for name, step_list in target_steps.items():
    print(f"\nExtracting for {name}:")
    for step_num in step_list:
        if step_num in step_map:
            tool, txt = step_map[step_num]
            out_file = os.path.join(output_dir, f"{name}_step_{step_num}_{tool}.txt")
            with open(out_file, "w", encoding="utf-8") as out:
                out.write(txt)
            print(f"  Extracted step {step_num} ({tool}) to {out_file} (Size: {len(txt)} chars)")
        else:
            print(f"  Step {step_num} not found in log.")
