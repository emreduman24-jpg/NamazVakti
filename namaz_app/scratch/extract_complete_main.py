kernel_path = r"C:\Users\kral_\Namaz vakitleri\namaz_app\build\app\intermediates\flutter\debug\flutter_assets\kernel_blob.bin"
target_file_path = "lib/screens/main_screen.dart"

with open(kernel_path, "rb") as f:
    data = f.read()

# Let's decode the entire kernel_blob.bin as utf-8, ignoring invalid bytes
# because the dill file has a lot of binary metadata, but also complete utf-8 strings of source files
text = data.decode("utf-8", errors="ignore")

# Find the location of class MainScreen
idx_class = text.find("class MainScreen extends StatefulWidget")
if idx_class == -1:
    print("FAILED to find MainScreen class.")
    exit(1)

# Search backward from idx_class to find the start of the file: "import 'dart:async';"
# There might be multiple matches in the entire dill, so let's find the nearest one going backwards
idx_start = text.rfind("import 'dart:async';", 0, idx_class)
if idx_start == -1:
    print("FAILED to find import statement.")
    exit(1)

# Find the end of the file. The file ends with the class SubtleMandalaPainter.
# Let's search forwards for "class SubtleMandalaPainter extends CustomPainter"
idx_painter = text.find("class SubtleMandalaPainter extends CustomPainter", idx_class)
if idx_painter == -1:
    print("FAILED to find SubtleMandalaPainter.")
    exit(1)

# Search for the shouldRepaint override and the closing brace of the painter class
# which marks the end of the main_screen.dart file.
idx_should_repaint = text.find("shouldRepaint(covariant CustomPainter oldDelegate) => false;", idx_painter)
if idx_should_repaint == -1:
    print("FAILED to find shouldRepaint inside painter.")
    exit(1)

# Find the very next "}" after shouldRepaint
idx_end = text.find("}", idx_should_repaint)
if idx_end == -1:
    print("FAILED to find final closing brace.")
    exit(1)

# We include the closing brace itself
idx_end += 1

extracted_code = text[idx_start:idx_end]

# Verify length and contents
print(f"Extracted code length: {len(extracted_code)} characters.")
print(f"Start block:\n{extracted_code[:200]}\n")
print(f"End block:\n{extracted_code[-200:]}\n")

# Write out the pristine restored code!
with open(target_file_path, "w", encoding="utf-8") as out:
    out.write(extracted_code)

print("PRISTINE main_screen.dart RESTORED SUCCESSFULLY!")
