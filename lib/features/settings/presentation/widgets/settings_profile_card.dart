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
import 'avatar_photo_action_dialog.dart';
import 'avatar_photo_cropper_dialog.dart';

/// Identifies the authenticated user at the top of the Settings screen.
/// Light glass card with a monogram avatar and soft blob decor, plus camera
/// (upload) and remove actions for the profile photo.
class SettingsProfileCard extends ConsumerStatefulWidget {
  const SettingsProfileCard({super.key, required this.auth});

  final AuthState auth;

  @override
  ConsumerState<SettingsProfileCard> createState() =>
      _SettingsProfileCardState();
}

class _SettingsProfileCardState extends ConsumerState<SettingsProfileCard> {
  final _picker = ImagePicker();
  bool _busy = false;

  AuthState get auth => widget.auth;

  Future<void> _onAvatarTap() async {
    if (_busy || !mounted) return;
    final displayName = auth.displayName?.trim();
    final name = displayName?.isNotEmpty == true ? displayName! : 'G';
    final action = await showAvatarPhotoActionDialog(
      context,
      name: name,
      avatarUrl: auth.avatarUrl,
      avatarVersion: auth.avatarVersion,
      canUseCamera: _picker.supportsImageSource(ImageSource.camera),
    );
    if (!mounted || action == null) return;
    if (action == AvatarPhotoAction.delete) {
      await _deleteAvatar();
      return;
    }
    await _pickCropAndUpload(
      action == AvatarPhotoAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );
  }

  Future<void> _pickCropAndUpload(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > maxAvatarSourceBytes) {
        if (mounted) {
          AppFeedback.error(
            context,
            AppLocalizations.of(context)!.settingsAvatarSourceTooLarge,
          );
        }
        return;
      }
      if (!mounted) return;
      final cropped = await showAvatarPhotoCropperDialog(
        context,
        sourceBytes: bytes,
      );
      if (cropped == null) return;
      final webp = encodeAvatarWebP(cropped);
      if (webp == null) {
        if (mounted) {
          AppFeedback.error(
            context,
            AppLocalizations.of(context)!.settingsAvatarInvalid,
          );
        }
        return;
      }
      if (!mounted) return;
      setState(() => _busy = true);
      await ref.read(authProvider.notifier).uploadAvatar(webp);
      if (mounted) {
        AppFeedback.success(
          context,
          AppLocalizations.of(context)!.settingsAvatarUpdated,
        );
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted && _busy) setState(() => _busy = false);
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
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
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
            child: RadialBlob(
              color: AppColors.blueAccent,
              size: 170,
              alpha: 0.14,
            ),
          ),
          const Positioned(
            bottom: -50,
            left: -40,
            child: RadialBlob(
              color: AppColors.violetAccent,
              size: 160,
              alpha: 0.10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: auth.avatarUrl == null
                      ? l10n.settingsAvatarUpload
                      : l10n.settingsAvatarChange,
                  child: InkWell(
                    onTap: _busy ? null : _onAvatarTap,
                    customBorder: const CircleBorder(),
                    child: UserAvatar(
                      name: name,
                      avatarUrl: auth.avatarUrl,
                      avatarVersion: auth.avatarVersion,
                      color: AppColors.navy,
                      size: 52,
                      boxShadow: AppColors.cardSoftShadow,
                    ),
                  ),
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
