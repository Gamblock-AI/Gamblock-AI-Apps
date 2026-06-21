import 'package:gamblock_ai_apps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Displays a generated group code with a copy button. Used after a Kepala
/// creates a monitoring group (PRD §2.2).
class GroupCodeDisplay extends StatefulWidget {
  final String groupCode;
  final String? groupName;

  const GroupCodeDisplay({super.key, required this.groupCode, this.groupName});

  @override
  State<GroupCodeDisplay> createState() => _GroupCodeDisplayState();
}

class _GroupCodeDisplayState extends State<GroupCodeDisplay> {
  bool _copied = false;

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.groupCode));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 56, color: AppColors.sage),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.onboardingGroupCreated,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColors.navy),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        if (widget.groupName != null)
          Text(widget.groupName!,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.navy.withValues(alpha: 0.6))),
        const SizedBox(height: 32),
        Text(AppLocalizations.of(context)!.onboardingGroupCode,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.navy.withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
          ),
          child: Text(widget.groupCode,
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: AppColors.navy)),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: _copyCode,
                  icon: Icon(_copied ? Icons.check : Icons.copy),
                  label: Text(_copied ? 'Tersalin' : 'Salin'))),
        ]),
      ],
    );
  }
}
