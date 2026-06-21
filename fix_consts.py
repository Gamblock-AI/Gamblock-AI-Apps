import re
import os

dart_files = []
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            dart_files.append(os.path.join(root, file))

# We need to remove 'const ' before any widget that now contains AppLocalizations
# A simple approach: find 'const ' followed by some chars and then 'AppLocalizations'
# But regex can be tricky. Let's just remove 'const ' if the line contains AppLocalizations.
# This might remove 'const ' from other things on the same line, but in Flutter it's usually fine.
# Actually, let's target specific patterns like 'const Text(AppLocalizations' and 'const AppBar(title: Text(AppLocalizations'

for file in dart_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    # ensure import is present if AppLocalizations is used
    if 'AppLocalizations.of' in content and "import 'package:flutter_gen/gen_l10n/app_localizations.dart';" not in content:
        import_stmt = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n"
        # Find first import or top of file
        idx = content.find('import ')
        if idx != -1:
            content = content[:idx] + import_stmt + content[idx:]
        else:
            content = import_stmt + content

    # Remove `const` before `Text(AppLocalizations`
    content = re.sub(r'const\s+(Text\(\s*AppLocalizations)', r'\1', content)
    # Remove `const` before `AppBar(title:\s*Text(AppLocalizations`
    content = re.sub(r'const\s+(AppBar\(\s*title:\s*Text\(\s*AppLocalizations)', r'\1', content)
    # Remove `const` before `AppBar(title:\s*AppLocalizations` just in case
    content = re.sub(r'const\s+(AppBar\(\s*title:\s*AppLocalizations)', r'\1', content)
    # Remove `const` before any `Widget` wrapping `AppLocalizations`?
    # Let's just find lines with `const ` and `AppLocalizations.of` and replace `const ` with ``
    # This is a bit aggressive but fixes 'const ' before parent widgets like 'const Padding(child: Text(AppLocalizations...))'
    lines = content.split('\n')
    for i in range(len(lines)):
        if 'AppLocalizations.of' in lines[i] and 'const ' in lines[i]:
            # Carefully remove `const ` only if it's before a widget tree containing AppLocalizations
            # A safe way is to replace 'const ' with '' if it's right before a known widget
            lines[i] = re.sub(r'const\s+([A-Z])', r'\1', lines[i])
            # Handle multiple consts on the same line
            lines[i] = re.sub(r'const\s+([A-Z])', r'\1', lines[i])

    # In `features/settings/settings_screen.dart`, there's `title: const Text('Accountability Partner')` which became `title: const Text(AppLocalizations.of(context)!.settingsAccountabilityPartner)`
    
    content = '\n'.join(lines)

    if content != original:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed const in {file}")

