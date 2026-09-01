import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/network/supabase_client_provider.dart';
import '../../errors/app_error.dart';

final fileUploadServiceProvider = Provider(
  (ref) => FileUploadService(ref.read(supabaseClientProvider)),
);

const _bucket = 'images';

class FileUploadService {
  final SupabaseClient _supabase;

  FileUploadService(this._supabase);

  Future<String> uploadProfileImage({
    required String filePath,
    required String uploadPath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("uploadProfileImage: file doesn't exist.");
    }

    try {
      // uploadPath comes in as "images/<uid>/..." (StorageConst.*UploadPath
      // helpers) - "images" here is the Supabase Storage *bucket* itself, so
      // strip that leading segment to avoid double-nesting, and so the RLS
      // policy's "first folder = auth.uid()" check lines up correctly.
      final objectPrefix = uploadPath.startsWith('$_bucket/') ? uploadPath.substring(_bucket.length + 1) : uploadPath;
      final extension = filePath.contains('.') ? filePath.split('.').last : 'jpg';
      final objectPath = '$objectPrefix/${const Uuid().v4()}.$extension';

      await _supabase.storage.from(_bucket).upload(
            objectPath,
            file,
            fileOptions: FileOptions(contentType: _contentTypeFor(extension)),
          );

      return _supabase.storage.from(_bucket).getPublicUrl(objectPath);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteUploadedImage(String imgUrl) async {
    try {
      final marker = '/object/public/$_bucket/';
      final index = imgUrl.indexOf(marker);
      if (index == -1) return;
      final objectPath = Uri.decodeFull(imgUrl.substring(index + marker.length));
      await _supabase.storage.from(_bucket).remove([objectPath]);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  String _contentTypeFor(String extension) {
    switch (extension.toLowerCase()) {
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
