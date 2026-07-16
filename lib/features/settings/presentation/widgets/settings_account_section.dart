import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/widgets/app_section_label.dart';

/// Account actions that vary between authenticated and anonymous sessions.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({
    super.key,
    required this.auth,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onManagePartner,
    required this.onLogin,
  });

  final AuthState auth;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onManagePartner;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        AppSectionLabel(title: l10n.settingsAccountSection),
        if (auth.isAuthenticated) ...[
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settingsEditProfile),
            onTap: onEditProfile,
          ),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.password),
            title: Text(l10n.settingsChangePassword),
            onTap: onChangePassword,
          ),
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.people_outline),
            title: Text(l10n.settingsAccountabilityPartner),
            onTap: onManagePartner,
          ),
        ] else
          ListTile(
            minTileHeight: 56,
            leading: const Icon(Icons.login),
            title: Text(l10n.authLoginBtn),
            onTap: onLogin,
          ),
      ],
    );
  }
}
