import sys

# Reconfigure stdout to use UTF-8
sys.stdout.reconfigure(encoding='utf-8')

def print_context(filepath, ranges):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    for r in ranges:
        print(f"=== Range {r[0]}-{r[1]} ===")
        start = max(0, r[0] - 8)
        end = min(len(lines), r[1] + 8)
        for i in range(start, end):
            print(lines[i].strip())
        print("\n")

print_context("scratch/reconstructed_main_partial.dart", [(130, 132), (661, 661), (873, 915)])
