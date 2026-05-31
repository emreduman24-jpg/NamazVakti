import sys
sys.stdout.reconfigure(encoding='utf-8')

with open("scratch/kernel_extracted.txt", "rb") as f:
    snippet = f.read()

text = snippet.decode("utf-8", errors="replace")
print("Snippet length in characters:", len(text))

# Let's search for "class MainScreen" in the decoded text
idx = text.find("class MainScreen")
if idx != -1:
    print(f"Found 'class MainScreen' in decoded text at {idx}!")
    # Print 2000 characters from there
    print("=== START OF EXTRACT ===")
    print(text[idx:idx+2500])
    print("=== END OF EXTRACT ===")
else:
    print("Could not find 'class MainScreen' in decoded text snippet.")
    print("First 1000 characters of snippet:")
    print(text[:1000])
