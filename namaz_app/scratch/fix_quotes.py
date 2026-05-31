with open("lib/screens/main_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Strip outer double quotes if present
if content.startswith('"') and content.endswith('"'):
    content = content[1:-1]

# Replace escapes
content = content.replace('\\n', '\n').replace('\\t', '\t').replace('\\"', '"').replace('\\\\', '\\')

with open("lib/screens/main_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("Quotes fixed successfully!")
