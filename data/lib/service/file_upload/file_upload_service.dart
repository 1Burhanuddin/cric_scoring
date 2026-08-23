import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/network/api_client.dart';
import '../../errors/app_error.dart';

final fileUploadServiceProvider = Provider(
  (ref) => FileUploadService(ref.read(apiClientProvider)),
);

class FileUploadService {
  final ApiClient _api;

  FileUploadService(this._api);

  Future<String> uploadProfileImage({
    required String filePath,
    required String uploadPath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("uploadProfileImage: file doesn't exist.");
    }

    try {
      final contentType = _contentTypeFor(filePath);
      final presign = await _api.post(
        '/uploads/presign',
        data: {
          'path': uploadPath,
          'filename': filePath.split(Platform.pathSeparator).last,
          'content_type': contentType,
        },
      ) as Map<String, dynamic>;

      final uploadUrl = presign['upload_url'] as String;
      final publicUrl = presign['public_url'] as String;

      // Uses a bare Dio instance (no interceptors) - this PUT goes straight to
      // R2's presigned URL, not our API, and must not carry our JWT bearer
      // token (R2 authenticates purely via the presigned query signature).
      await Dio().put(
        uploadUrl,
        data: await file.readAsBytes(),
        options: Options(headers: {'Content-Type': contentType}),
      );

      return publicUrl;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteUploadedImage(String imgUrl) async {
    try {
      await _api.post('/uploads/delete', data: {'url': imgUrl});
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  String _contentTypeFor(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
