import json
import re

log_path = r"C:\Users\kral_\.gemini\antigravity\brain\843361bf-1546-40fc-89a6-3009c3ea3406\.system_generated\logs\transcript.jsonl"

print("Searching transcript.jsonl...")

with open(log_path, 'r', encoding='utf-8') as f:
    for line_num, line in enumerate(f, 1):
        if "Widget _buildZikirmatik" in line or "Widget _buildKuranKerim" in line or "Widget _buildDiniHoca" in line or "namaz-vakitleri-aylik" in line:
            print(f"Match found at line {line_num}")
            # print first 200 characters of the line
            print(line[:300] + "...")
