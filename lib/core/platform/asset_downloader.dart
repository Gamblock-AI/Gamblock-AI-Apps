import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

/// Downloads Pattern Interrupt assets (videos, animations) on first launch
/// to keep the installer lean.
class AssetDownloader {
  static const _assets = [
    'https://gamblock-ai.vercel.app/assets/interrupt_meditation.lottie',
    'https://gamblock-ai.vercel.app/assets/interrupt_breathing.lottie',
    'https://gamblock-ai.vercel.app/assets/interrupt_calm.json',
  ];

  static bool _downloaded = false;

  /// Start downloading assets in background after first login
  static Future<void> downloadAll() async {
    if (_downloaded) return;

    final dir = await getApplicationDocumentsDirectory();
    final assetDir = Directory('${dir.path}/gamblock_assets');
    if (!await assetDir.exists()) {
      await assetDir.create(recursive: true);
    }

    for (final url in _assets) {
      try {
        final filename = url.split('/').last;
        final file = File('${assetDir.path}/$filename');

        if (await file.exists()) continue; // Already downloaded

        await Dio().download(url, file.path);
      } catch (_) {
        // Skip failed downloads — use fallback UI
      }
    }

    _downloaded = true;
  }

  /// Check if assets are available
  static Future<bool> areAssetsReady() async {
    final dir = await getApplicationDocumentsDirectory();
    final assetDir = Directory('${dir.path}/gamblock_assets');
    if (!await assetDir.exists()) return false;

    for (final url in _assets) {
      final filename = url.split('/').last;
      final file = File('${assetDir.path}/$filename');
      if (!await file.exists()) return false;
    }
    return true;
  }

  /// Get path to a downloaded asset
  static Future<String?> getAssetPath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/gamblock_assets/$filename');
    if (await file.exists()) return file.path;
    return null;
  }
}
