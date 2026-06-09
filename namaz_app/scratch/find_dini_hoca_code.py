import os
import json

edits_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_tool_edits_full"
output_file = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\dini_hoca_recovered.dart"

hoca_files = [
    "step_16734_0_replace_file_content.json",
    "step_16738_0_replace_file_content.json",
    "step_16744_0_replace_file_content.json",
    "step_16762_0_replace_file_content.json",
    "step_16766_0_replace_file_content.json",
    "step_16780_0_replace_file_content.json",
    "step_16786_0_replace_file_content.json",
    "step_16792_0_replace_file_content.json",
    "step_16796_0_replace_file_content.json",
    "step_16829_0_replace_file_content.json",
    "step_16831_0_replace_file_content.json",
    "step_16840_0_replace_file_content.json",
    "step_16925_0_replace_file_content.json",
    "step_16933_0_replace_file_content.json"
]

print("Scanning Dini Hoca steps...")

with open(output_file, "w", encoding="utf-8") as out:
    for filename in hoca_files:
        filepath = os.path.join(edits_dir, filename)
        if not os.path.exists(filepath):
            print(f"Skipping missing file {filename}")
            continue
            
        with open(filepath, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
            except Exception as e:
                print(f"Error reading {filename}: {e}")
                continue
                
            instruction = data.get("Instruction", "")
            repl = data.get("ReplacementContent", "")
            
            out.write(f"\n// ==========================================\n")
            out.write(f"// FILE: {filename}\n")
            out.write(f"// INSTRUCTION: {instruction}\n")
            out.write(f"// ==========================================\n")
            out.write(repl)
            out.write("\n")

print(f"Done! Saved all snippets to {output_file}")
