import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/course.dart';

/// Courses Repository Interface
abstract class CoursesRepository {
  Future<List<Course>> getCourses({bool forceRefresh = false});
  Future<Course?> getCourseById(int id);
  Future<void> saveCourse(String courseId);
  Future<void> unsaveCourse(String courseId);
  Future<void> enrollInCourse(String courseId);
  Future<SavedCoursesResult> getSavedCourses({int limit = 20, int offset = 0});
}

/// Courses Repository Implementation
class CoursesRepositoryImpl implements CoursesRepository {
  final ApiService _apiService;

  // Cache for courses
  List<Course>? _cachedCourses;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(
    minutes: 5,
  ); // Cache for 5 minutes

  CoursesRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<Course>> getCourses({bool forceRefresh = false}) async {
    try {
      // Check if we have valid cached data (only if not forcing refresh)
      if (!forceRefresh &&
          _cachedCourses != null &&
          _cacheTimestamp != null &&
          DateTime.now().difference(_cacheTimestamp!) < _cacheValidity) {
        debugPrint(
          '🔵 Returning cached courses (${_cachedCourses!.length} courses)',
        );
        return _cachedCourses!;
      }

      debugPrint('🔵 Fetching courses from API...');
      final response = await _apiService.getCourses();

      if (response.status) {
        // Cache the courses
        _cachedCourses = response.courses;
        _cacheTimestamp = DateTime.now();
        debugPrint(
          '✅ Courses cached successfully (${_cachedCourses!.length} courses)',
        );
        return response.courses;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // If API fails but we have cached data, return cached data
      if (_cachedCourses != null) {
        debugPrint('🔴 API failed, returning cached courses: ${e.toString()}');
        return _cachedCourses!;
      }
      throw Exception('Failed to fetch courses: ${e.toString()}');
    }
  }

  @override
  Future<Course?> getCourseById(int id) async {
    try {
      debugPrint('🔵 Fetching course by ID: $id');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot fetch course details');
        throw Exception('User must be logged in to view course details');
      }

      final response = await _apiService.get(
        '/courses/get-course_by_id.php?id=$id',
      );

      debugPrint(
        '🔵 Course Details API Response Status: ${response.statusCode}',
      );
      debugPrint('🔵 Course Details API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        final courseDetailsResponse = CourseDetailsResponse.fromJson(
          responseData,
        );

        if (courseDetailsResponse.status) {
          debugPrint('✅ Course details fetched successfully');
          return courseDetailsResponse.course;
        } else {
          debugPrint(
            '🔴 Course details fetch failed: ${responseData['message']}',
          );
          return null;
        }
      } else {
        debugPrint('🔴 Course details API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('🔴 Error fetching course by ID: $e');
      return null;
    }
  }

  @override
  Future<void> saveCourse(String courseId) async {
    try {
      final id = int.tryParse(courseId);
      if (id == null) {
        throw Exception('Invalid course ID: $courseId');
      }

      debugPrint('🔵 [CoursesRepository] Saving course with ID: $id');

      final response = await _apiService.saveCourse(courseId: id);
      
      debugPrint('🔵 [CoursesRepository] Save course response status: ${response.statusCode}');
      debugPrint('🔵 [CoursesRepository] Save course response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        final status = json['status'] == true;
        final message = json['message']?.toString() ?? '';
        
        debugPrint('🔵 [CoursesRepository] Response status: $status, message: $message');
        
        if (!status) {
          // Check for various success scenarios
          final messageLower = message.toLowerCase();
          final alreadySaved =
              json['already_saved'] == true ||
              messageLower.contains('already saved') ||
              messageLower.contains('course saved successfully');
          
          // Check if course not found or not available
          final courseNotFound = 
              messageLower.contains('not found') ||
              messageLower.contains('not available') ||
              messageLower.contains('course not found');
          
          if (courseNotFound) {
            throw Exception('Course not found or not available for saving');
          }
          
          if (!alreadySaved) {
            throw Exception(
              message.isNotEmpty ? message : 'Failed to save course',
            );
          } else {
            debugPrint('✅ [CoursesRepository] Course already saved (idempotent)');
          }
        } else {
          debugPrint('✅ [CoursesRepository] Course saved successfully');
        }
      } else {
        throw Exception('Failed to save course: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 [CoursesRepository] Error saving course: $e');
      rethrow;
    }
  }

  @override
  Future<void> unsaveCourse(String courseId) async {
    try {
      final id = int.tryParse(courseId);
      if (id == null) throw Exception('Invalid course ID');

      final response = await _apiService.unsaveCourse(courseId: id);
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        final status = json['status'] == true;
        if (!status) {
          // Treat not-saved as non-fatal success for idempotency
          final notSaved =
              (json['message']?.toString().toLowerCase().contains(
                "not saved",
              ) ??
              false);
          if (!notSaved) {
            throw Exception(
              json['message']?.toString() ?? 'Failed to unsave course',
            );
          }
        }
      } else {
        throw Exception('Failed to unsave course: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> enrollInCourse(String courseId) async {
    // TODO: Implement enroll in course API call when endpoint is available
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<SavedCoursesResult> getSavedCourses({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.getSavedCourses(
        limit: limit,
        offset: offset,
      );
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          final List<Map<String, dynamic>> courses = data.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            // Normalize to UI map
            return <String, dynamic>{
              'id': (map['course_id'] ?? '').toString(),
              'title': map['title'] ?? map['course_title'] ?? '',
              'description': map['description'] ?? '',
              'duration': map['duration']?.toString() ?? '',
              'mode': map['mode']?.toString() ?? '',
              'fee': map['fee'],
              'status': map['status']?.toString() ?? '',
              'course_created_at': map['course_created_at']?.toString() ?? '',
              'saved_at': map['saved_at']?.toString() ?? '',
              'category': map['category_name']?.toString() ?? '',
              'institute': map['institute_name']?.toString() ?? '',
              'isSaved': true,
            };
          }).toList();

          final ids = data
              .map((item) => (item['course_id'] ?? '').toString())
              .where((id) => id.isNotEmpty)
              .toSet();

          return SavedCoursesResult(courses: courses, savedCourseIds: ids);
        } else {
          throw Exception(
            json['message']?.toString() ?? 'Failed to load saved courses',
          );
        }
      } else {
        throw Exception('Failed to load saved courses: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// Result for saved courses fetch
class SavedCoursesResult {
  final List<Map<String, dynamic>> courses;
  final Set<String> savedCourseIds;

  SavedCoursesResult({required this.courses, required this.savedCourseIds});
}
