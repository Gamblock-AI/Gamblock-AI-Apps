import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class ApprovalDraft {
  const ApprovalDraft({
    required this.action,
    required this.reason,
    required this.durationMinutes,
  });

  final String action;
  final String reason;
  final int durationMinutes;
}

class ApprovalRequestDialog extends StatefulWidget {
  const ApprovalRequestDialog({super.key});

  @override
  State<ApprovalRequestDialog> createState() => _ApprovalRequestDialogState();
}

class _ApprovalRequestDialogState extends State<ApprovalRequestDialog> {
  final _reasonController = TextEditingController();
  String _action = 'pause_protection';
  int _duration = 30;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.navyGradient,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navyDark.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.sky,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.protectionApprovalDialogTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          l10n.protectionApprovalDialogBody,
                          style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _action,
                decoration: InputDecoration(
                  labelText: l10n.protectionActionLabel,
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        const BorderSide(color: AppColors.navy, width: 1.5),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'pause_protection',
                    child: Text(l10n.protectionPauseAction,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  DropdownMenuItem(
                    value: 'uninstall_detected',
                    child: Text(l10n.protectionUninstallAction,
                        style: const TextStyle(fontSize: 13)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _action = value);
                },
              ),
              if (_action == 'pause_protection') ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: _duration,
                  decoration: InputDecoration(
                    labelText: l10n.protectionDurationLabel,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide:
                          const BorderSide(color: AppColors.navy, width: 1.5),
                    ),
                  ),
                  items: [15, 30, 60, 120]
                      .map(
                        (minutes) => DropdownMenuItem(
                          value: minutes,
                          child: Text(l10n.minutesCount(minutes),
                              style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _duration = value);
                  },
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _reasonController,
                onChanged: (_) => setState(() {}),
                minLines: 2,
                maxLines: 3,
                maxLength: 240,
                decoration: InputDecoration(
                  labelText: l10n.protectionReasonLabel,
                  helperText: l10n.protectionReasonHelp,
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        const BorderSide(color: AppColors.navy, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.muted,
                          foregroundColor: AppColors.navy,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          disabledBackgroundColor:
                              AppColors.navy.withValues(alpha: 0.25),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: _reasonController.text.trim().isEmpty
                            ? null
                            : () => Navigator.pop(
                                  context,
                                  ApprovalDraft(
                                    action: _action,
                                    reason: _reasonController.text.trim(),
                                    durationMinutes:
                                        _action == 'pause_protection'
                                            ? _duration
                                            : 0,
                                  ),
                                ),
                        child: Text(
                          l10n.submit,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
