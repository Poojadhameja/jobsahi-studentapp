import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class FilePickerHelper {
  /// Pick Resume File (PDF, DOC, DOCX, Images)
  static Future<PlatformFile?> pickResume() async {
    try {
      // Request storage permission (not needed on web)
      if (!kIsWeb) {
        final status = await Permission.storage.request();
        if (!status.isGranted && !status.isLimited) {
          return null;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.size > 0) {
        final file = result.files.single;
        // On web, path is null but bytes are available
        // On mobile, path is available
        if (kIsWeb ? file.bytes != null : file.path != null) {
          return file;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick Certificate File
  static Future<PlatformFile?> pickCertificate() async {
    try {
      // Request storage permission (not needed on web)
      if (!kIsWeb) {
        final status = await Permission.storage.request();
        if (!status.isGranted && !status.isLimited) {
          return null;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.size > 0) {
        final file = result.files.single;
        // On web, path is null but bytes are available
        // On mobile, path is available
        if (kIsWeb ? file.bytes != null : file.path != null) {
          return file;
        }
      }
      return null;
    } catch (e) {
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
      // Request storage permission (not needed on web)
      if (!kIsWeb) {
        final status = await Permission.storage.request();
        if (!status.isGranted && !status.isLimited) {
          return null;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.size > 0) {
        final file = result.files.single;
        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          return null; // File too large
        }
        // On web, path is null but bytes are available
        // On mobile, path is available
        if (kIsWeb ? file.bytes != null : file.path != null) {
          return file;
        }
      }
      return null;
    } catch (e) {
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
