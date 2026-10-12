import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/supabase_service.dart';

/// Shared helper for uploading images and videos to Supabase Storage.
class MediaUploadHelper {
  /// Uploads a [file] to [bucket] and returns its public URL.
  /// [folder] is an optional sub-path (e.g. 'styles', 'services').
  /// [contentType] should be 'image/jpeg', 'image/png', or 'video/mp4'.
  static Future<String> uploadFile({
    required File file,
    required String bucket,
    required String folder,
    required String contentType,
  }) async {
    final ext = contentType.contains('video') ? 'mp4' : 'jpg';
    final fileName = '$folder/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await SupabaseService.client.storage.from(bucket).upload(
          fileName,
          file,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    return SupabaseService.client.storage.from(bucket).getPublicUrl(fileName);
  }

  /// Picks an image from the gallery and uploads it.
  /// Returns the public URL or null if cancelled / error.
  static Future<String?> pickAndUploadImage({
    required String bucket,
    required String folder,
    int imageQuality = 80,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
      );
      if (picked == null) return null;

      return uploadFile(
        file: File(picked.path),
        bucket: bucket,
        folder: folder,
        contentType: 'image/jpeg',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[UPLOAD] pickAndUploadImage error: $e');
      rethrow;
    }
  }

  /// Picks a video from the gallery and uploads it.
  /// Returns the public URL or null if cancelled / error.
  static Future<String?> pickAndUploadVideo({
    required String bucket,
    required String folder,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      if (picked == null) return null;

      return uploadFile(
        file: File(picked.path),
        bucket: bucket,
        folder: folder,
        contentType: 'video/mp4',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[UPLOAD] pickAndUploadVideo error: $e');
      rethrow;
    }
  }
}
