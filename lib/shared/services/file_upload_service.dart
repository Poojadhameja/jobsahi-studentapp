import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../../core/utils/app_constants.dart';
import 'token_storage.dart';

class FileUploadService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  FileUploadService({Dio? dio, TokenStorage? tokenStorage})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ),
      _tokenStorage = tokenStorage ?? TokenStorage.instance;

  /// Get Auth Headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenStorage.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    };
  }

  /// Upload Resume to R2
  Future<Map<String, dynamic>> uploadResume(PlatformFile file) async {
    try {
      // On web, file.path is null, so we use file.bytes instead
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File bytes are null');
        }
      } else {
        if (file.path == null) {
          throw Exception('File path is null');
        }
      }

      final headers = await _getAuthHeaders();

      // Create FormData - handle web vs mobile differently
      final MultipartFile multipartFile;
      if (kIsWeb) {
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      final formData = FormData.fromMap({'resume': multipartFile});

      debugPrint('🔵 [FileUpload] Uploading resume: ${file.name}');

      // Make request
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.resumeUploadEndpoint}',
        data: formData,
        options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('🔵 [FileUpload] Response status: ${response.statusCode}');
      debugPrint('🔵 [FileUpload] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Resume uploaded successfully',
        };
      } else {
        final errorMsg =
            response.data['message'] ?? 'Upload failed. Please try again.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🔴 [FileUpload] Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Upload Certificate to R2
  Future<Map<String, dynamic>> uploadCertificate(PlatformFile file) async {
    try {
      // On web, file.path is null, so we use file.bytes instead
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File bytes are null');
        }
      } else {
        if (file.path == null) {
          throw Exception('File path is null');
        }
      }

      final headers = await _getAuthHeaders();

      // Create FormData - handle web vs mobile differently
      final MultipartFile multipartFile;
      if (kIsWeb) {
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      final formData = FormData.fromMap({'certificate': multipartFile});

      debugPrint('🔵 [FileUpload] Uploading certificate: ${file.name}');

      // Make request
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.certificatesUploadEndpoint}',
        data: formData,
        options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('🔵 [FileUpload] Response status: ${response.statusCode}');
      debugPrint('🔵 [FileUpload] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message':
              response.data['message'] ?? 'Certificate uploaded successfully',
        };
      } else {
        final errorMsg =
            response.data['message'] ?? 'Upload failed. Please try again.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🔴 [FileUpload] Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Upload Profile Image to R2
  Future<Map<String, dynamic>> uploadProfileImage(PlatformFile file) async {
    try {
      // On web, file.path is null, so we use file.bytes instead
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File bytes are null');
        }
      } else {
        if (file.path == null) {
          throw Exception('File path is null');
        }
      }

      // Check file size (max 5MB for images)
      if (file.size > 5 * 1024 * 1024) {
        throw Exception('File size exceeds 5MB limit');
      }

      // Check file extension (only JPG, JPEG, PNG)
      final ext = file.name.toLowerCase().split('.').last;
      if (!['jpg', 'jpeg', 'png'].contains(ext)) {
        throw Exception('Invalid file type. Allowed: JPG, JPEG, PNG');
      }

      final headers = await _getAuthHeaders();

      // Create FormData - handle web vs mobile differently
      final MultipartFile multipartFile;
      if (kIsWeb) {
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      final formData = FormData.fromMap({
        'profile_image': multipartFile,
      });

      debugPrint('🔵 [FileUpload] Uploading profile image: ${file.name}');

      // Make request
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.profileImageUploadEndpoint}',
        data: formData,
        options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('🔵 [FileUpload] Response status: ${response.statusCode}');
      debugPrint('🔵 [FileUpload] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
          'message':
              response.data['message'] ?? 'Profile image uploaded successfully',
        };
      } else {
        final errorMsg =
            response.data['message'] ?? 'Upload failed. Please try again.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🔴 [FileUpload] Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
