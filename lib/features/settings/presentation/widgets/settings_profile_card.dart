import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/avatar_image_utils.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/brand_widgets.dart';

/// Identifies the authenticated user at the top of the Settings screen.
/// Light glass card with a monogram avatar and soft blob decor, plus camera
/// (upload) and remove actions for the profile photo.
class SettingsProfileCard extends ConsumerStatefulWidget {
  const SettingsProfileCard({super.key, required this.auth});

  final AuthState auth;

  @override
  ConsumerState<SettingsProfileCard> createState() => _SettingsProfileCardState();
}

class _SettingsProfileCardState extends ConsumerState<SettingsProfileCard> {
  final _picker = ImagePicker();
  bool _busy = false;

  AuthState get auth => widget.auth;

  Future<void> _pickAndUpload() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final webp = encodeAvatarWebP(bytes);
      if (webp == null) {
        if (mounted) {
          AppFeedback.error(
            context,
            AppLocalizations.of(context)!.settingsAvatarInvalid,
          );
        }
        return;
      }
      await ref.read(authProvider.notifier).uploadAvatar(webp);
      if (mounted) {
        AppFeedback.success(
          context,
          AppLocalizations.of(context)!.settingsAvatarUpdated,
        );
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.error(
          context,
          AppMessages.friendlyMessage(context, error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAvatar() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).deleteAvatar();
      if (mounted) {
        AppFeedback.success(
          context,
          AppLocalizations.of(context)!.settingsAvatarRemoved,
        );
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.error(
          context,
          AppMessages.friendlyMessage(context, error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = auth.displayName?.trim();
    final name = displayName?.isNotEmpty == true ? displayName! : 'G';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: AppColors.background),
        boxShadow: AppColors.cardSoftShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -40,
            top: -40,
            child: RadialBlob(color: AppColors.blueAccent, size: 170, alpha: 0.14),
          ),
          const Positioned(
            bottom: -50,
            left: -40,
            child: RadialBlob(color: AppColors.violetAccent, size: 160, alpha: 0.10),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Stack(
                  children: [
                    UserAvatar(
                      name: name,
                      avatarUrl: auth.avatarUrl,
                      avatarVersion: auth.avatarVersion,
                      color: AppColors.navy,
                      size: 52,
                      boxShadow: AppColors.cardSoftShadow,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _AvatarActionButton(
                        tooltip: auth.avatarUrl == null
                            ? l10n.settingsAvatarUpload
                            : l10n.settingsAvatarChange,
                        icon: Icons.photo_camera_rounded,
                        busy: _busy,
                        onPressed: _pickAndUpload,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.displayName ?? l10n.settingsUserFallback,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.email ?? '',
                        style: const TextStyle(
                          color: AppColors.inkMuted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _CapabilityChip(
                            icon: auth.phoneVerified
                                ? Icons.check_circle_rounded
                                : Icons.pending_rounded,
                            label: auth.phoneVerified
                                ? l10n.settingsWhatsappVerified
                                : l10n.settingsWhatsappUnverified,
                            active: auth.phoneVerified,
                          ),
                          if (auth.avatarUrl != null)
                            InkWell(
                              onTap: _busy ? null : _deleteAvatar,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.crimson.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.crimson.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 12,
                                      color: AppColors.crimson,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.settingsAvatarRemove,
                                      style: const TextStyle(
                                        color: AppColors.crimson,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarActionButton extends StatelessWidget {
  const _AvatarActionButton({
    required this.tooltip,
    required this.icon,
    required this.busy,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: busy ? null : onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: busy
              ? const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 14, color: AppColors.navy),
        ),
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.sage : AppColors.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
