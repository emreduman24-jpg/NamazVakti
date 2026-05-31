import re

kernel_path = r"C:\Users\kral_\Namaz vakitleri\namaz_app\build\app\intermediates\flutter\debug\flutter_assets\kernel_blob.bin"

with open(kernel_path, "rb") as f:
    data = f.read()

print(f"Read {len(data)} bytes of kernel_blob.bin")

# Search for the string "class MainScreen extends StatefulWidget" or similar
# Let's search using bytes
target = b"class MainScreen extends StatefulWidget"
idx = data.find(target)
if idx == -1:
    target = b"_MainScreenState"
    idx = data.find(target)

if idx != -1:
    print(f"Found target at index {idx}!")
    # Let's print 20000 bytes around the index as string
    start = max(0, idx - 10000)
    end = min(len(data), idx + 30000)
    snippet = data[start:end]
    
    # Let's write the snippet to a text file for inspection
    with open("scratch/kernel_extracted.txt", "wb") as out:
        out.write(snippet)
    print("SUCCESS: Wrote extracted snippet to scratch/kernel_extracted.txt")
else:
    print("FAILED TO FIND TARGET STRING IN KERNEL")
