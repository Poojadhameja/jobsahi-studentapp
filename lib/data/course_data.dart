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
      'category': 'Electrical',
      'duration': '6 Months',
      'fees': 25000,
      'rating': 4.5,
      'totalRatings': 180,
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
      'institute': 'Bharat Heavy Electricals Ltd.',
      'level': 'Beginner',
      'isSaved': false,
    },
    {
      'id': 'course_2',
      'title': 'ITI Fitter',
      'titleEnglish': 'ITI Fitter Course',
      'category': 'Mechanical',
      'duration': '8 Months',
      'fees': 30000,
      'rating': 4.3,
      'totalRatings': 120,
      'description':
          'ITI Fitter कोर्स मैकेनिकल फिटिंग और असेंबली के क्षेत्र में कैरियर बनाने के लिए डिज़ाइन किया गया है।',
      'fullDescription':
          'ITI Fitter कोर्स मैकेनिकल फिटिंग और असेंबली के क्षेत्र में कैरियर बनाने के लिए डिज़ाइन किया गया है। यह कोर्स छात्रों को मशीन पार्ट्स की फिटिंग, असेंबली, डिसमेंटलिंग और मेंटेनेंस के बारे में सिखाता है।',
      'benefits': [
        'प्रैक्टिकल वर्कशॉप सेशन',
        'उद्योग मानक उपकरणों का उपयोग',
        'हाथों-हाथ प्रशिक्षण',
        'प्लेसमेंट सहायता',
        'सर्टिफिकेशन',
      ],
      'imageUrl': 'assets/images/courses/fitter.png',
      'institute': 'Maruti Suzuki Training Institute',
      'level': 'Intermediate',
      'isSaved': false,
    },
    {
      'id': 'course_3',
      'title': 'ITI Welder',
      'titleEnglish': 'ITI Welding Course',
      'category': 'Welding',
      'duration': '4 Months',
      'fees': 20000,
      'rating': 4.7,
      'totalRatings': 95,
      'description':
          'ITI Welder कोर्स वेल्डिंग तकनीकों में विशेषज्ञता प्राप्त करने के लिए बनाया गया है।',
      'fullDescription':
          'ITI Welder कोर्स वेल्डिंग तकनीकों में विशेषज्ञता प्राप्त करने के लिए बनाया गया है। यह कोर्स ARC, MIG, TIG वेल्डिंग के साथ-साथ सुरक्षा प्रोटोकॉल और गुणवत्ता नियंत्रण पर ध्यान केंद्रित करता है।',
      'benefits': [
        'विभिन्न वेल्डिंग तकनीकों का प्रशिक्षण',
        'सुरक्षा प्रोटोकॉल का ज्ञान',
        'प्रैक्टिकल प्रोजेक्ट्स',
        'उद्योग प्रमाणन',
        'कैरियर मार्गदर्शन',
      ],
      'imageUrl': 'assets/images/courses/welder.png',
      'institute': 'Tata Motors Training Center',
      'level': 'Beginner',
      'isSaved': true,
    },
    {
      'id': 'course_4',
      'title': 'ITI Machinist',
      'titleEnglish': 'ITI Machining Course',
      'category': 'Machining',
      'duration': '10 Months',
      'fees': 35000,
      'rating': 4.6,
      'totalRatings': 140,
      'description':
          'ITI Machinist कोर्स CNC और पारंपरिक मशीनिंग तकनीकों में विशेषज्ञता प्रदान करता है।',
      'fullDescription':
          'ITI Machinist कोर्स CNC और पारंपरिक मशीनिंग तकनीकों में विशेषज्ञता प्रदान करता है। यह कोर्स लैथ, मिलिंग, ड्रिलिंग और CNC प्रोग्रामिंग के बारे में सिखाता है।',
      'benefits': [
        'CNC मशीनिंग प्रशिक्षण',
        'पारंपरिक मशीनिंग तकनीकें',
        'CAD/CAM सॉफ्टवेयर',
        'प्रैक्टिकल प्रोजेक्ट्स',
        'उद्योग प्लेसमेंट',
      ],
      'imageUrl': 'assets/images/courses/machinist.png',
      'institute': 'Mahindra Training Institute',
      'level': 'Advanced',
      'isSaved': false,
    },
    {
      'id': 'course_5',
      'title': 'ITI Turner',
      'titleEnglish': 'ITI Turning Course',
      'category': 'Turning',
      'duration': '6 Months',
      'fees': 28000,
      'rating': 4.4,
      'totalRatings': 110,
      'description':
          'ITI Turner कोर्स लैथ मशीन पर मेटल टर्निंग और शेपिंग में विशेषज्ञता प्रदान करता है।',
      'fullDescription':
          'ITI Turner कोर्स लैथ मशीन पर मेटल टर्निंग और शेपिंग में विशेषज्ञता प्रदान करता है। यह कोर्स छात्रों को सटीक मापन, टूल सेटअप और क्वालिटी कंट्रोल के बारे में सिखाता है।',
      'benefits': [
        'लैथ मशीन प्रशिक्षण',
        'टूल सेटअप और कैलिब्रेशन',
        'सटीक मापन तकनीकें',
        'क्वालिटी कंट्रोल प्रोसेस',
        'हाथों-हाथ प्रैक्टिस',
      ],
      'imageUrl': 'assets/images/courses/turner.png',
      'institute': 'Hero MotoCorp Training Center',
      'level': 'Intermediate',
      'isSaved': false,
    },
    {
      'id': 'course_6',
      'title': 'ITI Carpenter',
      'titleEnglish': 'ITI Carpentry Course',
      'category': 'Woodwork',
      'duration': '5 Months',
      'fees': 22000,
      'rating': 4.2,
      'totalRatings': 85,
      'description':
          'ITI Carpenter कोर्स लकड़ी के काम और फर्नीचर बनाने में विशेषज्ञता प्रदान करता है।',
      'fullDescription':
          'ITI Carpenter कोर्स लकड़ी के काम और फर्नीचर बनाने में विशेषज्ञता प्रदान करता है। यह कोर्स छात्रों को लकड़ी की कटिंग, जॉइनिंग, फिनिशिंग और फर्नीचर डिज़ाइन के बारे में सिखाता है।',
      'benefits': [
        'लकड़ी के काम की बुनियादी तकनीकें',
        'फर्नीचर बनाने का प्रशिक्षण',
        'टूल्स और मशीनरी का उपयोग',
        'डिज़ाइन और प्लानिंग',
        'प्रैक्टिकल वर्कशॉप',
      ],
      'imageUrl': 'assets/images/courses/carpenter.png',
      'institute': 'Hindustan Unilever Training Institute',
      'level': 'Beginner',
      'isSaved': false,
    },
    {
      'id': 'course_7',
      'title': 'ITI Plumber',
      'titleEnglish': 'ITI Plumbing Course',
      'category': 'Plumbing',
      'duration': '4 Months',
      'fees': 18000,
      'rating': 4.1,
      'totalRatings': 75,
      'description':
          'ITI Plumber कोर्स पाइपिंग और प्लंबिंग सिस्टम में विशेषज्ञता प्रदान करता है।',
      'fullDescription':
          'ITI Plumber कोर्स पाइपिंग और प्लंबिंग सिस्टम में विशेषज्ञता प्रदान करता है। यह कोर्स छात्रों को पाइप फिटिंग, वाल्व इंस्टॉलेशन, ड्रेनेज सिस्टम और प्लंबिंग कोड के बारे में सिखाता है।',
      'benefits': [
        'पाइपिंग सिस्टम का ज्ञान',
        'वाल्व और फिटिंग्स का प्रशिक्षण',
        'ड्रेनेज सिस्टम',
        'प्लंबिंग कोड और सुरक्षा',
        'प्रैक्टिकल इंस्टॉलेशन',
      ],
      'imageUrl': 'assets/images/courses/plumber.png',
      'institute': 'L&T Construction Training Center',
      'level': 'Beginner',
      'isSaved': false,
    },
    {
      'id': 'course_8',
      'title': 'ITI Draughtsman',
      'titleEnglish': 'ITI Drafting Course',
      'category': 'Drafting',
      'duration': '12 Months',
      'fees': 40000,
      'rating': 4.8,
      'totalRatings': 160,
      'description':
          'ITI Draughtsman कोर्स टेक्निकल ड्राइंग और CAD में विशेषज्ञता प्रदान करता है।',
      'fullDescription':
          'ITI Draughtsman कोर्स टेक्निकल ड्राइंग और CAD में विशेषज्ञता प्रदान करता है। यह कोर्स छात्रों को इंजीनियरिंग ड्राइंग, AutoCAD, 3D मॉडलिंग और प्रोजेक्ट डॉक्यूमेंटेशन के बारे में सिखाता है।',
      'benefits': [
        'टेक्निकल ड्राइंग स्किल्स',
        'AutoCAD प्रशिक्षण',
        '3D मॉडलिंग',
        'प्रोजेक्ट डॉक्यूमेंटेशन',
        'उद्योग सॉफ्टवेयर',
      ],
      'imageUrl': 'assets/images/courses/draughtsman.png',
      'institute': 'Bharat Forge Training Institute',
      'level': 'Advanced',
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
