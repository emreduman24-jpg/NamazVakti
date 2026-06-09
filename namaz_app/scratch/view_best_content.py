import os

scratch_dir = r"C:\Users\kral_\.gemini\antigravity\scratch"

def print_file_snippet(filename):
    filepath = os.path.join(scratch_dir, filename)
    if not os.path.exists(filepath):
        print(f"File {filename} does not exist.")
        return
    print(f"\n=================== {filename}Snippet ===================")
    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        for idx in range(50):
            line = f.readline()
            if not line:
                break
            # print line by removing non-ascii or replacing them safely
            safe_line = line.strip().encode('ascii', errors='replace').decode('ascii')
            print(f"{idx+1}: {safe_line}")

print_file_snippet("best_buildAylikNamazVakitleri.dart")
print_file_snippet("best_buildDiniHoca.dart")
print_file_snippet("best_buildKuranKerim.dart")
print_file_snippet("best_buildGunlukDualar.dart")
