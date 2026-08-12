import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../network/api_client.dart';
import '../theme/app_colors.dart';
import 'monogram_avatar.dart';

/// Authenticated avatar image with a monogram fallback.
///
/// The backend serves avatars from an auth-protected route
/// (`/v1/users/:id/avatar`), so the image bytes are fetched through [ApiClient]
/// (which attaches the bearer token and refreshes on 401) and rendered from
/// memory. While loading, or when there is no avatar / the fetch fails, the
/// monogram initials circle is shown instead.
class UserAvatar extends StatefulWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.avatarVersion = 0,
    this.color = AppColors.navy,
    this.size = 48,
    this.fontSize,
    this.boxShadow,
    this.border,
    this.gradient,
  });

  final String name;
  final String? avatarUrl;

  /// Bumped by [AuthState.applyAvatar] so a replaced avatar bypasses the
  /// in-memory image cache (the backend route is stable).
  final int avatarVersion;
  final Color color;
  final double size;
  final double? fontSize;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final Gradient? gradient;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Future<Uint8List>? _fetch;

  @override
  void initState() {
    super.initState();
    _fetch = widget.avatarUrl == null ? null : _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl ||
        oldWidget.avatarVersion != widget.avatarVersion) {
      _fetch = widget.avatarUrl == null ? null : _loadAvatar();
    }
  }

  String get _path {
    final raw = widget.avatarUrl ?? '';
    return '$raw${raw.contains('?') ? '&' : '?'}v=${widget.avatarVersion}';
  }

  Future<Uint8List> _loadAvatar() async {
    final response = await ApiClient.dio.get<List<int>>(
      _path,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Avatar response is empty');
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final fallback = MonogramAvatar(
      label: widget.name,
      color: widget.color,
      size: widget.size,
      fontSize: widget.fontSize,
      boxShadow: widget.boxShadow,
      border: widget.border,
      gradient: widget.gradient,
    );
    final fetch = _fetch;
    if (fetch == null) return fallback;
    return FutureBuilder<Uint8List>(
      future: fetch,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError) {
          return fallback;
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) return fallback;
        return MonogramAvatar(
          label: widget.name,
          color: widget.color,
          size: widget.size,
          fontSize: widget.fontSize,
          boxShadow: widget.boxShadow,
          border: widget.border,
          gradient: widget.gradient,
          image: MemoryImage(bytes),
        );
      },
    );
  }
}
