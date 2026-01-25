import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'supabase_config.dart';

/// Servicio para manejar storage de imágenes en Supabase
class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  // Configuración de compresión
  static const int maxWidth = 512;
  static const int maxHeight = 512;
  static const int quality = 80;

  /// Selecciona una imagen de la galería o cámara y la sube
  Future<String?> pickAndUploadImage({
    required ImageSource source,
    required String folder, // 'avatars', 'groups', etc.
    String? oldImageUrl, // Para eliminar la imagen anterior
  }) async {
    try {
      // 1. Seleccionar imagen
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024, // Pre-limit antes de comprimir
        maxHeight: 1024,
      );

      if (pickedFile == null) return null;

      // 2. Comprimir imagen
      final compressedBytes = await _compressImage(File(pickedFile.path));
      if (compressedBytes == null) return null;

      // 3. Generar nombre único
      final fileName = '${_uuid.v4()}.jpg';
      final filePath = '$folder/$fileName';

      // 4. Eliminar imagen anterior si existe
      if (oldImageUrl != null) {
        await _deleteImageByUrl(oldImageUrl);
      }

      // 5. Subir a Supabase Storage
      await _client.storage
          .from(SupabaseConfig.imagesBucket)
          .uploadBinary(
            filePath,
            compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // 6. Obtener URL pública
      final publicUrl = _client.storage
          .from(SupabaseConfig.imagesBucket)
          .getPublicUrl(filePath);

      debugPrint('[StorageService] Image uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[StorageService] Error uploading image: $e');
      return null;
    }
  }

  /// Comprime y redimensiona una imagen
  Future<Uint8List?> _compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      debugPrint('[StorageService] Error compressing image: $e');
      return null;
    }
  }

  /// Elimina una imagen por su URL pública
  Future<void> _deleteImageByUrl(String url) async {
    try {
      // Extraer el path del URL
      // URL format: https://xxx.supabase.co/storage/v1/object/public/bucket/path
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Buscar el índice después de 'public' y el nombre del bucket
      final publicIndex = pathSegments.indexOf('public');
      if (publicIndex == -1 || publicIndex + 2 >= pathSegments.length) return;

      final filePath = pathSegments.sublist(publicIndex + 2).join('/');

      await _client.storage
          .from(SupabaseConfig.imagesBucket)
          .remove([filePath]);

      debugPrint('[StorageService] Image deleted: $filePath');
    } catch (e) {
      debugPrint('[StorageService] Error deleting image: $e');
    }
  }

  /// Sube una imagen desde bytes (útil para web)
  Future<String?> uploadImageBytes({
    required Uint8List bytes,
    required String folder,
    String? oldImageUrl,
  }) async {
    try {
      // Generar nombre único
      final fileName = '${_uuid.v4()}.jpg';
      final filePath = '$folder/$fileName';

      // Eliminar imagen anterior si existe
      if (oldImageUrl != null) {
        await _deleteImageByUrl(oldImageUrl);
      }

      // Subir a Supabase Storage
      await _client.storage
          .from(SupabaseConfig.imagesBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Obtener URL pública
      final publicUrl = _client.storage
          .from(SupabaseConfig.imagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('[StorageService] Error uploading image bytes: $e');
      return null;
    }
  }
}
