import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/brand_widgets.dart';

enum AvatarPhotoAction { gallery, camera, delete }

/// Presents the profile-photo actions after the user taps their avatar.
Future<AvatarPhotoAction?> showAvatarPhotoActionDialog(
  BuildContext context, {
  required String name,
  required String? avatarUrl,
  required int avatarVersion,
  required bool canUseCamera,
}) {
  return showDialog<AvatarPhotoAction>(
    context: context,
    builder: (_) => _AvatarPhotoActionDialog(
      name: name,
      avatarUrl: avatarUrl,
      avatarVersion: avatarVersion,
      canUseCamera: canUseCamera,
    ),
  );
}

class _AvatarPhotoActionDialog extends StatefulWidget {
  const _AvatarPhotoActionDialog({
    required this.name,
    required this.avatarUrl,
    required this.avatarVersion,
    required this.canUseCamera,
  });

  final String name;
  final String? avatarUrl;
  final int avatarVersion;
  final bool canUseCamera;

  @override
  State<_AvatarPhotoActionDialog> createState() =>
      _AvatarPhotoActionDialogState();
}

class _AvatarPhotoActionDialogState extends State<_AvatarPhotoActionDialog> {
  bool _confirmingDelete = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasAvatar = widget.avatarUrl != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
            boxShadow: AppColors.softShadow,
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -40,
                left: -30,
                child: RadialBlob(
                  color: AppColors.sky,
                  size: 180,
                  alpha: 0.14,
                ),
              ),
              const Positioned(
                bottom: -40,
                right: -30,
                child: RadialBlob(
                  color: AppColors.sage,
                  size: 150,
                  alpha: 0.08,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
                child: _confirmingDelete
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.crimson.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 30,
                              color: AppColors.crimson,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.settingsAvatarDeleteTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.navyDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.settingsAvatarDeleteBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.pill,
                                      ),
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  onPressed: () => setState(
                                    () => _confirmingDelete = false,
                                  ),
                                  child: Text(
                                    l10n.cancel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navyDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.crimson,
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.pill,
                                      ),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(
                                    context,
                                    AvatarPhotoAction.delete,
                                  ),
                                  child: Text(
                                    l10n.settingsAvatarRemove,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.navyDark.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: UserAvatar(
                                  name: widget.name,
                                  avatarUrl: widget.avatarUrl,
                                  avatarVersion: widget.avatarVersion,
                                  color: AppColors.navy,
                                  size: 88,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.5,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.navy,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.2,
                                    ),
                                    boxShadow: AppColors.cardSoftShadow,
                                  ),
                                  child: const Icon(
                                    Icons.photo_camera_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.settingsAvatarDialogTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.navyDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 19,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            l10n.settingsAvatarDialogBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _AvatarActionTile(
                            icon: Icons.photo_library_outlined,
                            iconColor: AppColors.navy,
                            iconBgColor: AppColors.sky.withValues(alpha: 0.14),
                            title: l10n.settingsAvatarChooseGallery,
                            onTap: () => Navigator.pop(
                              context,
                              AvatarPhotoAction.gallery,
                            ),
                          ),
                          if (widget.canUseCamera) ...[
                            const SizedBox(height: 10),
                            _AvatarActionTile(
                              icon: Icons.photo_camera_outlined,
                              iconColor: AppColors.sage,
                              iconBgColor: AppColors.sage.withValues(
                                alpha: 0.14,
                              ),
                              title: l10n.settingsAvatarUseCamera,
                              onTap: () => Navigator.pop(
                                context,
                                AvatarPhotoAction.camera,
                              ),
                            ),
                          ],
                          if (hasAvatar) ...[
                            const SizedBox(height: 10),
                            _AvatarActionTile(
                              icon: Icons.delete_outline_rounded,
                              iconColor: AppColors.crimson,
                              iconBgColor: AppColors.crimson.withValues(
                                alpha: 0.12,
                              ),
                              title: l10n.settingsAvatarRemove,
                              isDestructive: true,
                              onTap: () => setState(
                                () => _confirmingDelete = true,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarActionTile extends StatelessWidget {
  const _AvatarActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDestructive
          ? AppColors.crimson.withValues(alpha: 0.05)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDestructive
                  ? AppColors.crimson.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDestructive
                        ? AppColors.crimson
                        : AppColors.navyDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDestructive
                    ? AppColors.crimson.withValues(alpha: 0.5)
                    : AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
