def print_context(filepath, ranges):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    for r in ranges:
        print(f"=== Range {r[0]}-{r[1]} ===")
        start = max(0, r[0] - 5)
        end = min(len(lines), r[1] + 5)
        for i in range(start, end):
            print(lines[i].strip())
        print("\n")

print_context("scratch/perfect_main_partial_v2.dart", [(101, 148), (391, 394), (661, 661), (873, 915)])
