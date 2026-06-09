import os
import json

recovered_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\recovered_codes"
clean_dir = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\recovered_clean_dart"
os.makedirs(clean_dir, exist_ok=True)

files = os.listdir(recovered_dir)

for filename in files:
    if not filename.endswith("_details.txt"):
        continue
    
    filepath = os.path.join(recovered_dir, filename)
    name = filename.replace("_details.txt", "")
    
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Extract only the replacement code part
    if "--- Replacement Content ---" in content:
        code_part = content.split("--- Replacement Content ---")[1].strip()
    elif "--- Replacement Chunks ---" in content:
        code_part = content.split("--- Replacement Chunks ---")[1].strip()
    else:
        code_part = content
        
    # Unescape literal newlines and quotes if they are escaped as string representation
    if code_part.startswith('"') and code_part.endswith('"'):
        code_part = code_part[1:-1]
        
    # Replace escaped characters
    code_part = code_part.replace('\\n', '\n')
    code_part = code_part.replace('\\"', '"')
    code_part = code_part.replace("\\'", "'")
    code_part = code_part.replace('\\t', '\t')
    code_part = code_part.replace('\\\\', '\\')
    
    out_path = os.path.join(clean_dir, f"{name}.dart")
    with open(out_path, "w", encoding="utf-8") as out:
        out.write(code_part)
        
    print(f"Generated clean Dart file: {out_path}")
