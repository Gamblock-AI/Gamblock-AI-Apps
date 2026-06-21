import os
import re
import json

dart_files = []
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            dart_files.append(os.path.join(root, file))

# Regex to find single quotes and double quotes strings
pattern = re.compile(r"""(['"])(.*?)\1""")

results = {}
for file in dart_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    matches = pattern.findall(content)
    # Filter strings that contain spaces and a capital letter, likely UI strings
    ui_strings = set()
    for match in matches:
        s = match[1]
        if ' ' in s and re.search(r'[a-zA-Z]', s) and not re.search(r'^[a-z_A-Z0-9/]+$', s) and not s.startswith('package:'):
            ui_strings.add(s)
        # also capture simple title words like 'Pengaturan', 'Keluar', 'Masuk'
        if s in ['Pengaturan', 'Keluar', 'Masuk', 'Batal', 'Kirim', 'Daftar', 'Dashboard', 'Pemulihan', 'Proteksi', 'Member', 'Kepala', 'Email', 'Password', 'Simpan']:
            ui_strings.add(s)
    if ui_strings:
        results[file] = list(ui_strings)

for k, v in results.items():
    print(k, v)

