import os
import json
import re

with open('translation_map.json', 'r') as f:
    strings = json.load(f)

# Convert dictionary so longest strings are matched first to avoid partial replacement
sorted_strings = sorted(strings.items(), key=lambda x: len(x[0]), reverse=True)

dart_files = []
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            dart_files.append(os.path.join(root, file))

for file in dart_files:
    if file.endswith('app_messages.dart'):
        continue
    
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # Check if we need to add import
    needs_import = False
    for indo, key in sorted_strings:
        # We look for 'indo' or "indo" or interpolation
        # Actually it's safer to just replace 'indo' and "indo"
        pattern1 = f"'{re.escape(indo)}'"
        pattern2 = f'"{re.escape(indo)}"'
        if re.search(pattern1, content) or re.search(pattern2, content):
            needs_import = True
            replacement = f"AppLocalizations.of(context)!.{key}"
            content = re.sub(pattern1, replacement, content)
            content = re.sub(pattern2, replacement, content)

    # friendlyMessage fix
    if 'AppMessages.friendlyMessage(e)' in content:
        needs_import = True
        content = content.replace('AppMessages.friendlyMessage(e)', 'AppMessages.friendlyMessage(context, e)')
    if 'AppMessages.friendlyMessage(' in content and 'context' not in content:
        # Just manually handling this if there's any
        pass

    if needs_import and original_content != content:
        # add import if not present
        if "import 'package:flutter_gen/gen_l10n/app_localizations.dart';" not in content:
            # find first import
            import_idx = content.find('import ')
            if import_idx != -1:
                content = content[:import_idx] + "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n" + content[import_idx:]
            else:
                content = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n" + content
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {file}")
