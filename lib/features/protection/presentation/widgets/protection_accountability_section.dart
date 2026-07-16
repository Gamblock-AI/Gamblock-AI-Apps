import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../accountability/domain/entities/accountability_models.dart';
import 'protection_accountability_card.dart';

/// Selects the appropriate accountability state for the current session.
class ProtectionAccountabilitySection extends StatelessWidget {
  const ProtectionAccountabilitySection({
    super.key,
    required this.auth,
    required this.partners,
    required this.requests,
    required this.emergencyRequest,
    required this.isLoading,
    required this.onRequestApproval,
    required this.onApplyApproval,
    required this.onManagePartner,
    required this.onRequestEmergency,
    required this.onEnterEmergencyKey,
    required this.onLogin,
    required this.onOpenSetup,
  });

  final AuthState auth;
  final PartnerOverview? partners;
  final List<ApprovalRequest> requests;
  final EmergencyRequest? emergencyRequest;
  final bool isLoading;
  final VoidCallback onRequestApproval;
  final ValueChanged<ApprovalRequest> onApplyApproval;
  final VoidCallback onManagePartner;
  final VoidCallback onRequestEmergency;
  final VoidCallback onEnterEmergencyKey;
  final VoidCallback onLogin;
  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.protectionAccountabilityTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        if (!auth.isAuthenticated)
          EmptyState(
            icon: Icons.lock_outline,
            title: l10n.protectionSignInTitle,
            hint: l10n.protectionSignInBody,
            actionLabel: l10n.authLoginBtn,
            onAction: onLogin,
          )
        else if (auth.deviceId == null)
          EmptyState(
            icon: Icons.phonelink_erase,
            title: l10n.deviceRegistrationMissing,
            hint: l10n.deviceRegistrationMissingBody,
            actionLabel: l10n.setupTitle,
            onAction: onOpenSetup,
          )
        else
          ProtectionAccountabilityCard(
            partners: partners,
            requests: requests,
            emergencyRequest: emergencyRequest,
            isLoading: isLoading,
            onRequestApproval: onRequestApproval,
            onApplyApproval: onApplyApproval,
            onManagePartner: onManagePartner,
            onRequestEmergency: onRequestEmergency,
            onEnterEmergencyKey: onEnterEmergencyKey,
          ),
      ],
    );
  }
}
