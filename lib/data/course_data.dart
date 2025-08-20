/// Course Data
/// Static data for courses, categories, and related information

library;

import '../../utils/app_constants.dart';

class CourseData {
  // Private constructor to prevent instantiation
  CourseData._();

  /// Course categories for filtering
  static List<String> get categories => AppConstants.courseCategories;

  /// Course levels for filtering
  static List<String> get levels => AppConstants.courseLevels;

  /// Sample course data
  static final List<Map<String, dynamic>> featuredCourses = [
    {
      'id': 'course_1',
      'title': 'इलेक्ट्रीशियन अप्रेंटिस',
      'titleEnglish': 'Electrician Apprentice',
      'category': 'Value',
      'duration': '1 Month',
      'fees': 15000,
      'rating': 4.0,
      'totalRatings': 150,
      'description':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है।',
      'fullDescription':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है। वास्तविक, व्यावहारिक अनुप्रयोगों के साथ डिज़ाइन किया गया यह कोर्स छात्रों को वायरिंग, सुरक्षा मानकों और आधुनिक विद्युत प्रणालियों के आवश्यक ज्ञान से लैस करता है।',
      'benefits': [
        'असली दुनिया के उपकरणों और सॉफ्टवेयर के साथ प्रैक्टिकल लैब सेशन',
        'उद्योग विशेषज्ञों से आमने-सामने मार्गदर्शन',
        'ऑन-साइट प्रशिक्षण और व्यावहारिक गैंक प्रोजेक्ट',
        'स्थानीय विद्युत ठेकेदारों के साथ नेटवर्किंग के अवसर',
        'लक्षित वायरिंग सिस्टम का अध्ययन करने के लिए सुरक्षित, मार्गदर्शित वातावरण',
      ],
      'imageUrl': 'assets/images/courses/electrician.png',
      'institute': 'Top Institute',
      'level': 'Beginner',
      'isSaved': false,
    },
    {
      'id': 'course_2',
      'title': 'इलेक्ट्रीशियन अप्रेंटिस',
      'titleEnglish': 'Electrician Apprentice',
      'category': 'Value',
      'duration': '1 Month',
      'fees': 15000,
      'rating': 4.0,
      'totalRatings': 150,
      'description':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है।',
      'fullDescription':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है। वास्तविक, व्यावहारिक अनुप्रयोगों के साथ डिज़ाइन किया गया यह कोर्स छात्रों को वायरिंग, सुरक्षा मानकों और आधुनिक विद्युत प्रणालियों के आवश्यक ज्ञान से लैस करता है।',
      'benefits': [
        'असली दुनिया के उपकरणों और सॉफ्टवेयर के साथ प्रैक्टिकल लैब सेशन',
        'उद्योग विशेषज्ञों से आमने-सामने मार्गदर्शन',
        'ऑन-साइट प्रशिक्षण और व्यावहारिक गैंक प्रोजेक्ट',
        'स्थानीय विद्युत ठेकेदारों के साथ नेटवर्किंग के अवसर',
        'लक्षित वायरिंग सिस्टम का अध्ययन करने के लिए सुरक्षित, मार्गदर्शित वातावरण',
      ],
      'imageUrl': 'assets/images/courses/electrician.png',
      'institute': 'Top Institute',
      'level': 'Beginner',
      'isSaved': false,
    },
    {
      'id': 'course_3',
      'title': 'इलेक्ट्रीशियन अप्रेंटिस',
      'titleEnglish': 'Electrician Apprentice',
      'category': 'Value',
      'duration': '1 Month',
      'fees': 15000,
      'rating': 4.0,
      'totalRatings': 150,
      'description':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है।',
      'fullDescription':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है। वास्तविक, व्यावहारिक अनुप्रयोगों के साथ डिज़ाइन किया गया यह कोर्स छात्रों को वायरिंग, सुरक्षा मानकों और आधुनिक विद्युत प्रणालियों के आवश्यक ज्ञान से लैस करता है।',
      'benefits': [
        'असली दुनिया के उपकरणों और सॉफ्टवेयर के साथ प्रैक्टिकल लैब सेशन',
        'उद्योग विशेषज्ञों से आमने-सामने मार्गदर्शन',
        'ऑन-साइट प्रशिक्षण और व्यावहारिक गैंक प्रोजेक्ट',
        'स्थानीय विद्युत ठेकेदारों के साथ नेटवर्किंग के अवसर',
        'लक्षित वायरिंग सिस्टम का अध्ययन करने के लिए सुरक्षित, मार्गदर्शित वातावरण',
      ],
      'imageUrl': 'assets/images/courses/electrician.png',
      'institute': 'Top Institute',
      'level': 'Beginner',
      'isSaved': true,
    },
    {
      'id': 'course_4',
      'title': 'इलेक्ट्रीशियन अप्रेंटिस',
      'titleEnglish': 'Electrician Apprentice',
      'category': 'Value',
      'duration': '1 Month',
      'fees': 15000,
      'rating': 4.0,
      'totalRatings': 150,
      'description':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है।',
      'fullDescription':
          'इलेक्ट्रीशियन अप्रेंटिस कोर्स एक आधारभूत कार्यक्रम है जो किसी भी विद्युत व्यवसाय में प्रवेश करने की इच्छा रखने वालों के लिए बनाया गया है। वास्तविक, व्यावहारिक अनुप्रयोगों के साथ डिज़ाइन किया गया यह कोर्स छात्रों को वायरिंग, सुरक्षा मानकों और आधुनिक विद्युत प्रणालियों के आवश्यक ज्ञान से लैस करता है।',
      'benefits': [
        'असली दुनिया के उपकरणों और सॉफ्टवेयर के साथ प्रैक्टिकल लैब सेशन',
        'उद्योग विशेषज्ञों से आमने-सामने मार्गदर्शन',
        'ऑन-साइट प्रशिक्षण और व्यावहारिक गैंक प्रोजेक्ट',
        'स्थानीय विद्युत ठेकेदारों के साथ नेटवर्किंग के अवसर',
        'लक्षित वायरिंग सिस्टम का अध्ययन करने के लिए सुरक्षित, मार्गदर्शित वातावरण',
      ],
      'imageUrl': 'assets/images/courses/electrician.png',
      'institute': 'Top Institute',
      'level': 'Beginner',
      'isSaved': false,
    },
  ];

  /// Get courses by category
  static List<Map<String, dynamic>> getCoursesByCategory(String category) {
    if (category == 'All') {
      return featuredCourses;
    }
    return featuredCourses
        .where((course) => course['category'] == category)
        .toList();
  }

  /// Get courses by level
  static List<Map<String, dynamic>> getCoursesByLevel(String level) {
    if (level == 'All Levels') {
      return featuredCourses;
    }
    return featuredCourses.where((course) => course['level'] == level).toList();
  }

  /// Get saved courses
  static List<Map<String, dynamic>> getSavedCourses() {
    return featuredCourses
        .where((course) => course['isSaved'] == true)
        .toList();
  }

  /// Search courses by title
  static List<Map<String, dynamic>> searchCourses(String query) {
    if (query.isEmpty) {
      return featuredCourses;
    }

    final lowercaseQuery = query.toLowerCase();
    return featuredCourses.where((course) {
      final title = course['title'].toString().toLowerCase();
      final titleEnglish = course['titleEnglish'].toString().toLowerCase();
      final category = course['category'].toString().toLowerCase();

      return title.contains(lowercaseQuery) ||
          titleEnglish.contains(lowercaseQuery) ||
          category.contains(lowercaseQuery);
    }).toList();
  }

  /// Toggle course saved status
  static void toggleCourseSaved(String courseId) {
    final courseIndex = featuredCourses.indexWhere(
      (course) => course['id'] == courseId,
    );
    if (courseIndex != -1) {
      featuredCourses[courseIndex]['isSaved'] =
          !featuredCourses[courseIndex]['isSaved'];
    }
  }

  /// Get course by ID
  static Map<String, dynamic>? getCourseById(String courseId) {
    try {
      return featuredCourses.firstWhere((course) => course['id'] == courseId);
    } catch (e) {
      return null;
    }
  }
}
