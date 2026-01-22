import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/campus_drive.dart';
import '../models/campus_application.dart';

/// Abstract interface for campus drive repository
abstract class CampusDriveRepository {
  Future<List<CampusDrive>> getLiveDrives();
  Future<CampusDriveDetails> getDriveDetails(int driveId);
  Future<CampusApplication> applyToDrive({
    required int driveId,
    required List<Map<String, dynamic>> preferences,
  });
  Future<List<CampusApplication>> getMyApplications();
  Future<CampusApplication> getApplicationDetails(int applicationId);
  Future<CampusApplication> deletePreference({
    required int applicationId,
    required int preferenceNumber,
  });
}

/// Implementation of CampusDriveRepository
class CampusDriveRepositoryImpl implements CampusDriveRepository {
  final ApiService _apiService;

  CampusDriveRepositoryImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<CampusDrive>> getLiveDrives() async {
    try {
      debugPrint('🔵 [Campus Drive] Fetching live drives...');

      final response = await _apiService.get(
        '/campus_drive/candidate/get_live_drives.php',
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      if (responseData['status'] == true || responseData['status'] == 'success') {
        final data = responseData['data'] as List<dynamic>? ?? [];
        final drives = data
            .map((json) => CampusDrive.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✅ [Campus Drive] Fetched ${drives.length} live drives');
        return drives;
      } else {
        throw Exception(responseData['message']?.toString() ?? 'Failed to fetch live drives');
      }
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error fetching live drives: $e');
      rethrow;
    }
  }

  @override
  Future<CampusDriveDetails> getDriveDetails(int driveId) async {
    try {
      debugPrint('🔵 [Campus Drive] Fetching drive details for ID: $driveId');

      final response = await _apiService.get(
        '/campus_drive/candidate/get_drive_details.php',
        queryParameters: {'drive_id': driveId},
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      if (responseData['status'] == true || responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        final details = CampusDriveDetails.fromJson(data);

        debugPrint('✅ [Campus Drive] Fetched drive details successfully');
        return details;
      } else {
        throw Exception(responseData['message']?.toString() ?? 'Failed to fetch drive details');
      }
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error fetching drive details: $e');
      rethrow;
    }
  }

  @override
  Future<CampusApplication> applyToDrive({
    required int driveId,
    required List<Map<String, dynamic>> preferences,
  }) async {
    try {
      debugPrint('🔵 [Campus Drive] Applying to drive ID: $driveId');

      // Validate preferences (1 to 6 allowed)
      if (preferences.isEmpty || preferences.length > 6) {
        throw Exception('Please select between 1 and 6 company preferences');
      }

      // Check for duplicates
      final companyIds = preferences
          .map((p) => p['company_id'] as int?)
          .where((id) => id != null)
          .toList();
      if (companyIds.length != companyIds.toSet().length) {
        throw Exception('Duplicate company preferences are not allowed');
      }

      final response = await _apiService.post(
        '/campus_drive/candidate/apply_to_drive.php',
        data: {
          'drive_id': driveId,
          'preferences': preferences,
        },
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      if (responseData['status'] == true || responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        final application = CampusApplication.fromJson(data);

        debugPrint('✅ [Campus Drive] Application submitted successfully');
        return application;
      } else {
        throw Exception(responseData['message']?.toString() ?? 'Failed to submit application');
      }
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error applying to drive: $e');
      rethrow;
    }
  }

  @override
  Future<List<CampusApplication>> getMyApplications() async {
    try {
      debugPrint('🔵 [Campus Drive] Fetching my applications...');

      final response = await _apiService.get(
        '/campus_drive/candidate/get_my_applications.php',
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      if (responseData['status'] == true || responseData['status'] == 'success') {
        final data = responseData['data'] as List<dynamic>? ?? [];
        final applications = data
            .map((json) => CampusApplication.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✅ [Campus Drive] Fetched ${applications.length} applications');
        return applications;
      } else {
        throw Exception(responseData['message']?.toString() ?? 'Failed to fetch applications');
      }
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error fetching applications: $e');
      rethrow;
    }
  }

  @override
  Future<CampusApplication> getApplicationDetails(int applicationId) async {
    try {
      debugPrint('🔵 [Campus Drive] Fetching application details for ID: $applicationId');

      final response = await _apiService.get(
        '/campus_drive/candidate/get_application_details.php',
        queryParameters: {'application_id': applicationId},
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      if (responseData['status'] == true || responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        final application = CampusApplication.fromJson(data);

        debugPrint('✅ [Campus Drive] Fetched application details successfully');
        return application;
      } else {
        throw Exception(responseData['message']?.toString() ?? 'Failed to fetch application details');
      }
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error fetching application details: $e');
      rethrow;
    }
  }

  @override
  Future<CampusApplication> deletePreference({
    required int applicationId,
    required int preferenceNumber,
  }) async {
    try {
      debugPrint('🔵 [Campus Drive] Deleting preference $preferenceNumber from application ID: $applicationId');

      final response = await _apiService.post(
        '/campus_drive/candidate/delete_preference.php',
        data: {
          'application_id': applicationId,
          'preference_number': preferenceNumber,
        },
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      if (responseData['status'] == true || responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        final application = CampusApplication.fromJson(data);

        debugPrint('✅ [Campus Drive] Preference deleted successfully');
        return application;
      } else {
        throw Exception(responseData['message']?.toString() ?? 'Failed to delete preference');
      }
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error deleting preference: $e');
      rethrow;
    }
  }
}
