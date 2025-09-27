import '../../../shared/services/api_service.dart';
import '../models/course.dart';

/// Courses Repository Interface
abstract class CoursesRepository {
  Future<List<Course>> getCourses();
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
