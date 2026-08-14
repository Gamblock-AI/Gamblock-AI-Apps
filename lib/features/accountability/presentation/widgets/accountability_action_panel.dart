import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/accountability_models.dart';

/// Compact action hierarchy for sharing consent and leaving accountability.
class AccountabilityActionPanel extends StatelessWidget {
  const AccountabilityActionPanel({
    super.key,
    required this.pendingExitRequest,
    required this.isLoading,
    required this.onManageSharing,
    required this.onRequestLeave,
    required this.onCancelLeave,
  });

  final AccountabilityExitRequest? pendingExitRequest;
  final bool isLoading;
  final VoidCallback onManageSharing;
  final ValueChanged<String> onRequestLeave;
  final VoidCallback? onCancelLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exit = pendingExitRequest;
    final exitAccent = exit == null ? AppColors.crimson : AppColors.amberDark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onManageSharing,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.navy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.partnerSharingPrivacy,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyDark,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.partnerSharingDesc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.76),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.navy,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: exitAccent.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: exitAccent.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    exit == null
                        ? Icons.logout_rounded
                        : Icons.schedule_rounded,
                    color: exitAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exit == null
                            ? l10n.partnerLeaveSection
                            : l10n.accExitPendingTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDark,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exit == null
                            ? l10n.accExitChoose
                            : l10n.accExitPendingBody,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (exit?.canCancel == true)
                  TextButton(
                    onPressed: isLoading ? null : onCancelLeave,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.crimson,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else if (exit == null)
                  PopupMenuButton<String>(
                    enabled: !isLoading,
                    tooltip: l10n.partnerLeaveSection,
                    onSelected: onRequestLeave,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.navy,
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'normal',
                        child: Text(l10n.partnerLeaveNormal),
                      ),
                      PopupMenuItem(
                        value: 'unsafe',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppColors.crimson,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.partnerLeaveUnsafe,
                              style: const TextStyle(
                                color: AppColors.crimson,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
