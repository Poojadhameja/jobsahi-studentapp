import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/course.dart';

/// Courses Repository Interface
abstract class CoursesRepository {
  Future<List<Course>> getCourses();
  Future<Course?> getCourseById(int id);
  Future<void> saveCourse(String courseId);
  Future<void> unsaveCourse(String courseId);
  Future<void> enrollInCourse(String courseId);
}

/// Courses Repository Implementation
class CoursesRepositoryImpl implements CoursesRepository {
  final ApiService _apiService;

  CoursesRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<Course>> getCourses() async {
    try {
      final response = await _apiService.getCourses();
      if (response.status) {
        return response.courses;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
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
    // TODO: Implement save course API call when endpoint is available
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> unsaveCourse(String courseId) async {
    // TODO: Implement unsave course API call when endpoint is available
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> enrollInCourse(String courseId) async {
    // TODO: Implement enroll in course API call when endpoint is available
    await Future.delayed(const Duration(seconds: 2));
  }
}
