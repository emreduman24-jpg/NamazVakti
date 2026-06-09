import os
import json

edits_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_tool_edits"

selected_steps = {
    "Zikirmatik": "step_16032_0_replace_file_content.json",
    "KuranKerim": "step_14873_0_replace_file_content.json",
    "GunlukDualar": "step_16498_0_replace_file_content.json",
    "DiniHoca": "step_16831_0_replace_file_content.json",
    "AylikVakitler": "step_13044_0_replace_file_content.json",
    "KibleBulucu": "step_12955_0_replace_file_content.json"
}

output_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\recovered_codes"
os.makedirs(output_dir, exist_ok=True)

for name, filename in selected_steps.items():
    filepath = os.path.join(edits_dir, filename)
    if not os.path.exists(filepath):
        print(f"File {filename} not found!")
        continue
        
    with open(filepath, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
            args = data.get("arguments", {})
            
            # Write key information to a separate file for inspection
            out_path = os.path.join(output_dir, f"{name}_details.txt")
            with open(out_path, "w", encoding="utf-8") as out:
                out.write(f"=== {name} (Step {data.get('step_index')}) ===\n")
                out.write(f"Tool: {data.get('tool_name')}\n")
                out.write(f"Instruction: {args.get('Instruction', '')}\n")
                out.write(f"Description: {args.get('Description', '')}\n\n")
                
                if "ReplacementContent" in args:
                    out.write("--- Replacement Content ---\n")
                    out.write(args["ReplacementContent"])
                    out.write("\n")
                elif "ReplacementChunks" in args:
                    out.write("--- Replacement Chunks ---\n")
                    for chunk in args["ReplacementChunks"]:
                        out.write(f"Start: {chunk.get('StartLine')}, End: {chunk.get('EndLine')}\n")
                        out.write(f"Target: {chunk.get('TargetContent')}\n")
                        out.write(f"Replacement:\n{chunk.get('ReplacementContent')}\n\n")
            print(f"Dumped details for {name} to {out_path}")
        except Exception as e:
            print(f"Error parsing {filename}: {e}")
