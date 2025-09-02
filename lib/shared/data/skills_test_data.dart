/// Skills Test Data
/// API-compatible data structure for skills tests and questions

library;

class SkillsTestData {
  // Private constructor to prevent instantiation
  SkillsTestData._();

  /// Skills test model matching API response structure
  static Map<String, dynamic> get electricianTest => {
    'id': 'test_electrician_001',
    'title': 'इलेक्ट्रीशियन अप्रेंटिस',
    'titleEnglish': 'Electrician Apprentice',
    'provider': 'Satpuda ITI',
    'providerId': 'satpuda_iti_001',
    'duration': 25, // minutes - increased for 14 questions
    'totalQuestions': 14,
    'passingScore': 60, // percentage
    'maxAttempts': 3,
    'category': 'Electrical',
    'difficulty': 'Beginner',
    'description': 'ITI इलेक्ट्रीशियन के लिए आवश्यक स्किल टेस्ट',
    'instructions': [
      'सभी प्रश्न अनिवार्य हैं',
      'प्रत्येक प्रश्न के लिए केवल एक सही उत्तर है',
      'समय सीमा 25 मिनट है',
      'टेस्ट सबमिट करने के बाद परिणाम तुरंत मिलेगा',
    ],
    'createdAt': '2024-01-15T10:00:00Z',
    'updatedAt': '2024-01-15T10:00:00Z',
    'isActive': true,
  };

  /// Questions data structure matching API response
  static List<Map<String, dynamic>> get electricianQuestions => [
    {
      'id': 'q_elec_001',
      'testId': 'test_electrician_001',
      'questionNumber': 1,
      'question':
          '1. ITI की पढ़ाई के बाद कौन-कौन से स्किल टेस्ट जरूरी होते हैं?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_001_a', 'text': 'खेल परीक्षा', 'isCorrect': false},
        {'id': 'opt_001_b', 'text': 'तकनीकी कौशल परीक्षा', 'isCorrect': true},
        {'id': 'opt_001_c', 'text': 'सामान्य ज्ञान टेस्ट', 'isCorrect': false},
        {'id': 'opt_001_d', 'text': 'चित्रकला टेस्ट', 'isCorrect': false},
      ],
      'explanation': 'ITI के बाद तकनीकी कौशल परीक्षा सबसे महत्वपूर्ण है।',
      'points': 25,
    },
    {
      'id': 'q_elec_002',
      'testId': 'test_electrician_001',
      'questionNumber': 2,
      'question':
          '2. इलेक्ट्रिकल सर्किट में कौन सा कंपोनेंट करंट को नियंत्रित करता है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_002_a', 'text': 'रेजिस्टर', 'isCorrect': true},
        {'id': 'opt_002_b', 'text': 'कैपेसिटर', 'isCorrect': false},
        {'id': 'opt_002_c', 'text': 'इंडक्टर', 'isCorrect': false},
        {'id': 'opt_002_d', 'text': 'डायोड', 'isCorrect': false},
      ],
      'explanation':
          'रेजिस्टर करंट को नियंत्रित करने के लिए प्रयोग किया जाता है।',
      'points': 25,
    },
    {
      'id': 'q_elec_003',
      'testId': 'test_electrician_001',
      'questionNumber': 3,
      'question': '3. AC और DC में क्या अंतर है?',
      'questionType': 'multiple_choice',
      'options': [
        {
          'id': 'opt_003_a',
          'text': 'AC में वोल्टेज बदलता है, DC में नहीं',
          'isCorrect': false,
        },
        {
          'id': 'opt_003_b',
          'text': 'DC में करंट एक दिशा में बहता है',
          'isCorrect': false,
        },
        {
          'id': 'opt_003_c',
          'text': 'AC में फ्रीक्वेंसी होती है',
          'isCorrect': false,
        },
        {'id': 'opt_003_d', 'text': 'सभी सही हैं', 'isCorrect': true},
      ],
      'explanation': 'AC और DC में सभी अंतर सही हैं।',
      'points': 25,
    },
    {
      'id': 'q_elec_004',
      'testId': 'test_electrician_001',
      'questionNumber': 4,
      'question': '4. इलेक्ट्रिकल सेफ्टी के लिए क्या जरूरी है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_004_a', 'text': 'ग्राउंडिंग', 'isCorrect': false},
        {'id': 'opt_004_b', 'text': 'फ्यूज प्रोटेक्शन', 'isCorrect': false},
        {'id': 'opt_004_c', 'text': 'इंसुलेशन', 'isCorrect': false},
        {'id': 'opt_004_d', 'text': 'सभी सही हैं', 'isCorrect': true},
      ],
      'explanation': 'इलेक्ट्रिकल सेफ्टी के लिए सभी उपाय जरूरी हैं।',
      'points': 25,
    },
    {
      'id': 'q_elec_005',
      'testId': 'test_electrician_001',
      'questionNumber': 5,
      'question': '5. वेल्डिंग में कौन सी गैस सबसे ज्यादा प्रयोग होती है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_005_a', 'text': 'ऑक्सीजन', 'isCorrect': false},
        {'id': 'opt_005_b', 'text': 'कार्बन डाइऑक्साइड', 'isCorrect': true},
        {'id': 'opt_005_c', 'text': 'नाइट्रोजन', 'isCorrect': false},
        {'id': 'opt_005_d', 'text': 'हाइड्रोजन', 'isCorrect': false},
      ],
      'explanation':
          'कार्बन डाइऑक्साइड वेल्डिंग में सबसे ज्यादा प्रयोग होती है।',
      'points': 25,
    },
    {
      'id': 'q_elec_006',
      'testId': 'test_electrician_001',
      'questionNumber': 6,
      'question': '6. फिटिंग में कौन सा टूल सबसे महत्वपूर्ण है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_006_a', 'text': 'हैकसॉ', 'isCorrect': false},
        {'id': 'opt_006_b', 'text': 'फाइल', 'isCorrect': false},
        {'id': 'opt_006_c', 'text': 'वर्नियर कैलीपर्स', 'isCorrect': true},
        {'id': 'opt_006_d', 'text': 'स्क्रूड्राइवर', 'isCorrect': false},
      ],
      'explanation': 'वर्नियर कैलीपर्स सटीक मापन के लिए सबसे महत्वपूर्ण है।',
      'points': 25,
    },
    {
      'id': 'q_elec_007',
      'testId': 'test_electrician_001',
      'questionNumber': 7,
      'question':
          '7. मैकेनिकल ड्राइंग में कौन सा प्रोजेक्शन सबसे ज्यादा प्रयोग होता है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_007_a', 'text': 'आर्थोग्राफिक', 'isCorrect': true},
        {'id': 'opt_007_b', 'text': 'आइसोमेट्रिक', 'isCorrect': false},
        {'id': 'opt_007_c', 'text': 'ऑब्लिक', 'isCorrect': false},
        {'id': 'opt_007_d', 'text': 'पर्सपेक्टिव', 'isCorrect': false},
      ],
      'explanation':
          'आर्थोग्राफिक प्रोजेक्शन मैकेनिकल ड्राइंग में सबसे ज्यादा प्रयोग होता है।',
      'points': 25,
    },
    {
      'id': 'q_elec_008',
      'testId': 'test_electrician_001',
      'questionNumber': 8,
      'question': '8. टर्निंग में कौन सा कटिंग टूल सबसे ज्यादा प्रयोग होता है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_008_a', 'text': 'ड्रिल बिट', 'isCorrect': false},
        {'id': 'opt_008_b', 'text': 'टर्निंग टूल', 'isCorrect': true},
        {'id': 'opt_008_c', 'text': 'बोरिंग टूल', 'isCorrect': false},
        {'id': 'opt_008_d', 'text': 'थ्रेडिंग टूल', 'isCorrect': false},
      ],
      'explanation': 'टर्निंग टूल लैथ मशीन में सबसे ज्यादा प्रयोग होता है।',
      'points': 25,
    },
    {
      'id': 'q_elec_009',
      'testId': 'test_electrician_001',
      'questionNumber': 9,
      'question': '9. कौन सा मेटल सबसे ज्यादा कंडक्टिव है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_009_a', 'text': 'सिल्वर', 'isCorrect': true},
        {'id': 'opt_009_b', 'text': 'कॉपर', 'isCorrect': false},
        {'id': 'opt_009_c', 'text': 'अल्युमिनियम', 'isCorrect': false},
        {'id': 'opt_009_d', 'text': 'आयरन', 'isCorrect': false},
      ],
      'explanation': 'सिल्वर सबसे ज्यादा कंडक्टिव मेटल है।',
      'points': 25,
    },
    {
      'id': 'q_elec_010',
      'testId': 'test_electrician_001',
      'questionNumber': 10,
      'question': '10. वायरिंग में कौन सा कलर न्यूट्रल के लिए प्रयोग होता है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_010_a', 'text': 'लाल', 'isCorrect': false},
        {'id': 'opt_010_b', 'text': 'नीला', 'isCorrect': true},
        {'id': 'opt_010_c', 'text': 'काला', 'isCorrect': false},
        {'id': 'opt_010_d', 'text': 'हरा', 'isCorrect': false},
      ],
      'explanation': 'नीला कलर न्यूट्रल वायर के लिए प्रयोग होता है।',
      'points': 25,
    },
    {
      'id': 'q_elec_011',
      'testId': 'test_electrician_001',
      'questionNumber': 11,
      'question': '11. कौन सा मेटल वेल्डिंग के लिए सबसे उपयुक्त है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_011_a', 'text': 'स्टील', 'isCorrect': true},
        {'id': 'opt_011_b', 'text': 'कास्ट आयरन', 'isCorrect': false},
        {'id': 'opt_011_c', 'text': 'ब्रास', 'isCorrect': false},
        {'id': 'opt_011_d', 'text': 'एल्युमिनियम', 'isCorrect': false},
      ],
      'explanation': 'स्टील वेल्डिंग के लिए सबसे उपयुक्त मेटल है।',
      'points': 25,
    },
    {
      'id': 'q_elec_012',
      'testId': 'test_electrician_001',
      'questionNumber': 12,
      'question': '12. फाइलिंग में कौन सी फाइल सबसे ज्यादा प्रयोग होती है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_012_a', 'text': 'फ्लैट फाइल', 'isCorrect': true},
        {'id': 'opt_012_b', 'text': 'राउंड फाइल', 'isCorrect': false},
        {'id': 'opt_012_c', 'text': 'स्क्वायर फाइल', 'isCorrect': false},
        {'id': 'opt_012_d', 'text': 'ट्रायंगल फाइल', 'isCorrect': false},
      ],
      'explanation': 'फ्लैट फाइल सबसे ज्यादा प्रयोग होती है।',
      'points': 25,
    },
    {
      'id': 'q_elec_013',
      'testId': 'test_electrician_001',
      'questionNumber': 13,
      'question': '13. कौन सा मेटल सबसे ज्यादा कठोर है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_013_a', 'text': 'डायमंड', 'isCorrect': true},
        {'id': 'opt_013_b', 'text': 'स्टील', 'isCorrect': false},
        {'id': 'opt_013_c', 'text': 'टंगस्टन', 'isCorrect': false},
        {'id': 'opt_013_d', 'text': 'क्रोमियम', 'isCorrect': false},
      ],
      'explanation': 'डायमंड सबसे ज्यादा कठोर मेटल है।',
      'points': 25,
    },
    {
      'id': 'q_elec_014',
      'testId': 'test_electrician_001',
      'questionNumber': 14,
      'question':
          '14. इलेक्ट्रिकल मोटर में कौन सा कंपोनेंट रोटेशन पैदा करता है?',
      'questionType': 'multiple_choice',
      'options': [
        {'id': 'opt_014_a', 'text': 'स्टेटर', 'isCorrect': false},
        {'id': 'opt_014_b', 'text': 'रोटर', 'isCorrect': true},
        {'id': 'opt_014_c', 'text': 'कम्यूटेटर', 'isCorrect': false},
        {'id': 'opt_014_d', 'text': 'ब्रश', 'isCorrect': false},
      ],
      'explanation': 'रोटर इलेक्ट्रिकल मोटर में रोटेशन पैदा करता है।',
      'points': 25,
    },
  ];

  /// Get test by ID (API compatible method)
  static Map<String, dynamic>? getTestById(String testId) {
    if (testId == 'test_electrician_001') {
      return electricianTest;
    }
    return null;
  }

  /// Get questions for a specific test (API compatible method)
  static List<Map<String, dynamic>> getQuestionsByTestId(String testId) {
    if (testId == 'test_electrician_001') {
      return electricianQuestions;
    }
    return [];
  }

  /// Get all available tests (API compatible method)
  static List<Map<String, dynamic>> getAllTests() {
    return [electricianTest];
  }

  /// Calculate test results (API compatible method)
  static Map<String, dynamic> calculateResults({
    required String testId,
    required Map<String, String> userAnswers, // optionId -> questionId mapping
    required int timeTaken, // in seconds
  }) {
    final questions = getQuestionsByTestId(testId);
    final test = getTestById(testId);

    if (questions.isEmpty || test == null) {
      return {'error': 'Test not found', 'success': false};
    }

    int correctAnswers = 0;
    int wrongAnswers = 0;
    int totalPoints = 0;
    int earnedPoints = 0;

    List<Map<String, dynamic>> questionResults = [];

    for (var question in questions) {
      final questionId = question['id'] as String;
      final userAnswerId = userAnswers[questionId];
      final options = question['options'] as List<Map<String, dynamic>>;
      final points = question['points'] as int;

      totalPoints += points;

      // Find correct option
      final correctOption = options.firstWhere(
        (opt) => opt['isCorrect'] == true,
        orElse: () => options.first, // Fallback to first option if none found
      );

      // Check if user answer is correct
      bool isCorrect = false;
      if (userAnswerId != null) {
        final userOption = options.firstWhere(
          (opt) => opt['id'] == userAnswerId,
          orElse: () => options.first, // Fallback to first option if none found
        );
        isCorrect = userOption['isCorrect'] == true;
      }

      if (isCorrect) {
        correctAnswers++;
        earnedPoints += points;
      } else {
        wrongAnswers++;
      }

      questionResults.add({
        'questionId': questionId,
        'userAnswerId': userAnswerId,
        'correctAnswerId': correctOption['id'],
        'isCorrect': isCorrect,
        'points': points,
        'earnedPoints': isCorrect ? points : 0,
      });
    }

    final percentage = totalPoints > 0
        ? (earnedPoints / totalPoints * 100).round()
        : 0;
    final passed = percentage >= (test['passingScore'] as int);

    return {
      'success': true,
      'testId': testId,
      'totalQuestions': questions.length,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'unanswered': questions.length - (correctAnswers + wrongAnswers),
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'percentage': percentage,
      'passed': passed,
      'passingScore': test['passingScore'],
      'timeTaken': timeTaken,
      'timeLimit': test['duration'] * 60, // convert minutes to seconds
      'questionResults': questionResults,
      'completedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Submit test attempt (API compatible method)
  static Future<Map<String, dynamic>> submitTestAttempt({
    required String testId,
    required String userId,
    required Map<String, String> userAnswers,
    required int timeTaken,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final results = calculateResults(
      testId: testId,
      userAnswers: userAnswers,
      timeTaken: timeTaken,
    );

    if (results['success'] == true) {
      // In real implementation, this would save to backend
      return {
        'success': true,
        'attemptId': 'attempt_${DateTime.now().millisecondsSinceEpoch}',
        'results': results,
        'message': 'Test submitted successfully',
      };
    } else {
      return {
        'success': false,
        'error': results['error'],
        'message': 'Failed to submit test',
      };
    }
  }

  /// Get user's test attempts (API compatible method)
  static Future<List<Map<String, dynamic>>> getUserTestAttempts(
    String userId,
  ) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock data - in real implementation, this would come from backend
    return [
      {
        'id': 'attempt_001',
        'testId': 'test_electrician_001',
        'userId': userId,
        'score': 75,
        'percentage': 75,
        'passed': true,
        'timeTaken': 720, // 12 minutes
        'completedAt': '2024-01-10T14:30:00Z',
        'attempt': 1,
      },
    ];
  }

  /// Convert legacy question format to API format (for backward compatibility)
  static List<Map<String, dynamic>> convertLegacyQuestions(
    List<Map<String, dynamic>> legacyQuestions,
  ) {
    return legacyQuestions.map((q) {
      final options = (q['options'] as List<String>).asMap().entries.map((
        entry,
      ) {
        return {
          'id': 'opt_${entry.key}',
          'text': entry.value,
          'isCorrect': entry.key == 1, // Second option is correct by default
        };
      }).toList();

      return {
        'id': 'q_${legacyQuestions.indexOf(q)}',
        'question': q['question'],
        'questionType': 'multiple_choice',
        'options': options,
        'points': 25,
      };
    }).toList();
  }

  /// Helper method to get simplified question format for UI
  static List<Map<String, dynamic>> getSimplifiedQuestions(String testId) {
    final questions = getQuestionsByTestId(testId);
    return questions.map((q) {
      final options = (q['options'] as List<Map<String, dynamic>>)
          .map((opt) => opt['text'] as String)
          .toList();

      return {
        'question': q['question'],
        'options': options,
        'correctAnswer': (q['options'] as List<Map<String, dynamic>>)
            .indexWhere((opt) => opt['isCorrect'] == true),
      };
    }).toList();
  }
}
