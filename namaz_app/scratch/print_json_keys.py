import json

filepath = r"c:\Users\kral_\Namaz vakitleri\namaz_app\scratch\extracted_views\step_17290_view.json"
with open(filepath, "r", encoding="utf-8") as f:
    data = json.load(f)

print("Keys in the step JSON:")
for k, v in data.items():
    if isinstance(v, (str, int, float, bool)):
        print(f"  {k}: {v}")
    elif isinstance(v, list):
        print(f"  {k} (list of length {len(v)})")
    elif isinstance(v, dict):
        print(f"  {k} (dict with keys {list(v.keys())})")
