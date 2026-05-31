import json
import re

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\bfa70658-74aa-43c5-b71d-b66952b42f2e\.system_generated\logs\transcript.jsonl"

with open(log_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if "main_screen.dart" in line and "Showing lines 1 to" in line:
            try:
                data = json.loads(line)
                content = data.get("content", "")
                print(f"Log Line {i+1}: contains Showing lines 1 to ... length: {len(content)}")
                # Print the lines around 90-110 in the content
                lines = content.split("\n")
                print("Lines around 95-105:")
                for l in lines:
                    if l.strip().startswith("95:") or l.strip().startswith("96:") or l.strip().startswith("97:") or l.strip().startswith("98:") or l.strip().startswith("99:") or l.strip().startswith("100:") or l.strip().startswith("101:") or l.strip().startswith("102:") or l.strip().startswith("103:") or l.strip().startswith("104:") or l.strip().startswith("105:"):
                        print(l)
            except Exception as e:
                print(f"Error: {e}")
            break
