import 'dart:typed_data';

import 'package:image/image.dart' as img;

const maxAvatarSourceBytes = 8 << 20;
const maxAvatarUploadBytes = 2 << 20;

/// Prepares a picked image for upload as a square WebP avatar, mirroring the
/// web portal (512×512). Returns null when the source cannot be decoded.
Uint8List? encodeAvatarWebP(Uint8List sourceBytes) {
  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) return null;
  final square = img.copyResizeCropSquare(decoded, size: 512);
  final encoded = img.encodeWebP(square);
  return encoded.lengthInBytes <= maxAvatarUploadBytes ? encoded : null;
}
