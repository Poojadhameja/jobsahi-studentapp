import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';

class FilePickerHelper {
  /// Pick Resume File (PDF, DOC, DOCX, Images)
  static Future<PlatformFile?> pickResume() async {
    try {
      // File picker handles permissions internally via SAF (Storage Access Framework)
      // No need to request explicit permissions on Android 10+
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData:
            false, // Don't load file data immediately (better performance)
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        // Check if file has valid data
        if (file.size > 0) {
          // On web, path is null but bytes are available
          // On mobile, path is available
          if (kIsWeb ? file.bytes != null : file.path != null) {
            return file;
          }
        }
      }
      return null;
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      debugPrint('File picker error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('File picker error: $e');
      return null;
    }
  }

  /// Pick Certificate File
  static Future<PlatformFile?> pickCertificate() async {
    try {
      // File picker handles permissions internally via SAF (Storage Access Framework)
      // No need to request explicit permissions on Android 10+
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
        withData:
            false, // Don't load file data immediately (better performance)
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        // Check if file has valid data
        if (file.size > 0) {
          // On web, path is null but bytes are available
          // On mobile, path is available
          if (kIsWeb ? file.bytes != null : file.path != null) {
            return file;
          }
        }
      }
      return null;
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      debugPrint('File picker error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('File picker error: $e');
      return null;
    }
  }

  /// Get File Size in MB
  static String getFileSize(PlatformFile file) {
    final sizeInBytes = file.size;
    if (sizeInBytes < 1024) {
      return '${sizeInBytes} B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// Pick Profile Image (JPG, JPEG, PNG only)
  static Future<PlatformFile?> pickProfileImage() async {
    try {
      // File picker handles permissions internally via SAF (Storage Access Framework)
      // No need to request explicit permissions on Android 10+
      // For images, we can also use image picker, but file_picker works for all file types
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData:
            false, // Don't load file data immediately (better performance)
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        // Check if file has valid data
        if (file.size > 0) {
          // Check file size (max 5MB)
          if (file.size > 5 * 1024 * 1024) {
            debugPrint('File too large: ${file.size} bytes');
            return null; // File too large
          }
          // On web, path is null but bytes are available
          // On mobile, path is available
          if (kIsWeb ? file.bytes != null : file.path != null) {
            return file;
          }
        }
      }
      return null;
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      debugPrint('File picker error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('File picker error: $e');
      return null;
    }
  }

  /// Get File Extension
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }
}
