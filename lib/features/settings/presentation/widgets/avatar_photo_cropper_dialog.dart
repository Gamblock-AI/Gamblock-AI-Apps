import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

/// Lets a user prepare a square profile photo before it is encoded as WebP.
Future<Uint8List?> showAvatarPhotoCropperDialog(
  BuildContext context, {
  required Uint8List sourceBytes,
}) {
  return showDialog<Uint8List>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AvatarPhotoCropperDialog(sourceBytes: sourceBytes),
  );
}

class _AvatarPhotoCropperDialog extends StatefulWidget {
  const _AvatarPhotoCropperDialog({required this.sourceBytes});

  final Uint8List sourceBytes;

  @override
  State<_AvatarPhotoCropperDialog> createState() =>
      _AvatarPhotoCropperDialogState();
}

class _AvatarPhotoCropperDialogState extends State<_AvatarPhotoCropperDialog> {
  final CropController _controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTWH(0, 0, 1, 1),
  );
  double _zoom = 1;
  bool _editorReady = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setZoom(double value) {
    if (!_editorReady) return;
    final side = 1 / value;
    final currentCenter = _controller.crop.center;
    final half = side / 2;
    final center = Offset(
      currentCenter.dx.clamp(half, 1 - half).toDouble(),
      currentCenter.dy.clamp(half, 1 - half).toDouble(),
    );
    setState(() => _zoom = value);
    _controller.crop = Rect.fromCenter(
      center: center,
      width: side,
      height: side,
    );
  }

  void _reset() {
    if (!_editorReady) return;
    setState(() {
      _zoom = 1;
      _error = null;
    });
    _controller.rotation = CropRotation.up;
    _controller.crop = const Rect.fromLTWH(0, 0, 1, 1);
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final bitmap = await _controller.croppedBitmap(maxSize: 512);
      final data = await bitmap.toByteData(format: ui.ImageByteFormat.png);
      bitmap.dispose();
      if (data == null) throw StateError('Avatar crop is empty');
      if (!mounted) return;
      Navigator.pop(context, data.buffer.asUint8List());
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = AppLocalizations.of(context)!.settingsAvatarEditorFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsAvatarEditorTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsAvatarEditorBody,
                style: const TextStyle(color: AppColors.inkMuted, height: 1.4),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: AppColors.navy,
                      child: CropImage(
                        controller: _controller,
                        image: Image.memory(
                          widget.sourceBytes,
                          fit: BoxFit.contain,
                        ),
                        alwaysMove: true,
                        alwaysShowThirdLines: true,
                        maximumImageSize: 2048,
                        onCrop: (_) {
                          if (!_editorReady && mounted) {
                            setState(() => _editorReady = true);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.settingsAvatarRotateLeft,
                    onPressed: _saving || !_editorReady
                        ? null
                        : _controller.rotateLeft,
                    icon: const Icon(Icons.rotate_90_degrees_ccw_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.settingsAvatarRotateRight,
                    onPressed: _saving || !_editorReady
                        ? null
                        : _controller.rotateRight,
                    icon: const Icon(Icons.rotate_90_degrees_cw_rounded),
                  ),
                  TextButton.icon(
                    onPressed: _saving || !_editorReady ? null : _reset,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(l10n.settingsAvatarReset),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    l10n.settingsAvatarZoom,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Slider(
                      value: _zoom,
                      min: 1,
                      max: 3,
                      divisions: 40,
                      label: '${_zoom.toStringAsFixed(1)}×',
                      onChanged: _saving || !_editorReady ? null : _setZoom,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!, style: const TextStyle(color: AppColors.crimson)),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving || !_editorReady ? null : _finish,
                      child: Text(
                        _saving
                            ? l10n.settingsAvatarSaving
                            : l10n.settingsAvatarUsePhoto,
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
