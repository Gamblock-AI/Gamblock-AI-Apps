import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import '../theme/app_colors.dart';

/// Interactive language toggle button for Auth screens and Onboarding.
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isId = settings.locale.languageCode == 'id';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final nextLocale = isId ? const Locale('en') : const Locale('id');
          ref.read(appSettingsProvider.notifier).setLocale(nextLocale);
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language_rounded,
                size: 16,
                color: AppColors.navy,
              ),
              const SizedBox(width: 5),
              _langBadge('ID', active: isId),
              const SizedBox(width: 2),
              Text(
                '/',
                style: TextStyle(
                  color: AppColors.mutedForeground.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              _langBadge('EN', active: !isId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langBadge(String label, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: active ? AppColors.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.mutedForeground,
          fontSize: 10,
          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}
