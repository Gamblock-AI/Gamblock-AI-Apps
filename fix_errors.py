import re

# Fix shell.dart
with open('lib/app/shell.dart', 'r') as f:
    content = f.read()
content = content.replace('const [', '[').replace('const <Widget>[', '<Widget>[')
content = content.replace('const NavigationDestination', 'NavigationDestination')
with open('lib/app/shell.dart', 'w') as f:
    f.write(content)

# Fix organization_repository_impl.dart
with open('lib/features/onboarding/data/repositories/organization_repository_impl.dart', 'r') as f:
    content = f.read()
content = content.replace("Exception(AppLocalizations.of(context)!.errorInvalidGroupCode)", "DioException(requestOptions: RequestOptions(path: ''), response: Response(requestOptions: RequestOptions(path: ''), statusCode: 400, data: {'error': {'code': 'join_failed'}}))")
content = content.replace("Exception(AppLocalizations.of(context)!.errorCreateGroup)", "DioException(requestOptions: RequestOptions(path: ''), response: Response(requestOptions: RequestOptions(path: ''), statusCode: 400, data: {'error': {'code': 'create_org_failed'}}))")
with open('lib/features/onboarding/data/repositories/organization_repository_impl.dart', 'w') as f:
    f.write(content)

# Fix create_group_screen.dart SnackBar
with open('lib/features/onboarding/presentation/screens/create_group_screen.dart', 'r') as f:
    content = f.read()
content = content.replace('const SnackBar(', 'SnackBar(')
with open('lib/features/onboarding/presentation/screens/create_group_screen.dart', 'w') as f:
    f.write(content)

# Fix approval_request_dialog.dart
with open('lib/features/protection/presentation/widgets/approval_request_dialog.dart', 'r') as f:
    content = f.read()
content = content.replace('''AppLocalizations.of(context)!.protectionApprovalDesc
          AppLocalizations.of(context)!.protectionAppLockedDesc''', "AppLocalizations.of(context)!.protectionApprovalDesc + ' ' + AppLocalizations.of(context)!.protectionAppLockedDesc")
with open('lib/features/protection/presentation/widgets/approval_request_dialog.dart', 'w') as f:
    f.write(content)

# Fix recovery_screen.dart context in initializer
with open('lib/features/recovery/presentation/screens/recovery_screen.dart', 'r') as f:
    content = f.read()
# Find _missions and turn it into a getter
content = content.replace('final _missions = [', 'List<({String type, String title})> get _missions => [')
with open('lib/features/recovery/presentation/screens/recovery_screen.dart', 'w') as f:
    f.write(content)

# Fix journal_tab.dart invalid constants
with open('lib/features/recovery/presentation/widgets/journal_tab.dart', 'r') as f:
    content = f.read()
content = content.replace('final _reflections = [', 'List<ReflectionEntry> get _reflections => [')
content = content.replace('const ReflectionEntry', 'ReflectionEntry')
with open('lib/features/recovery/presentation/widgets/journal_tab.dart', 'w') as f:
    f.write(content)

# Fix settings_screen.dart remaining consts
with open('lib/features/settings/settings_screen.dart', 'r') as f:
    content = f.read()
content = content.replace('const ListTile', 'ListTile')
content = content.replace('const AlertDialog', 'AlertDialog')
content = content.replace('const CircularProgressIndicator', 'CircularProgressIndicator')
with open('lib/features/settings/settings_screen.dart', 'w') as f:
    f.write(content)

