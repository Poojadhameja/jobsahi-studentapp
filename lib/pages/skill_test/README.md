# Skill Test Pages

This directory contains the skill test functionality for the Job Sahi app.

## Pages Overview

### 1. `skill_test.dart` - Skill Test List
- Displays available skill tests for a specific job category
- Shows test information like MCQs count, time limit, passing marks
- Allows filtering by skill level (Beginner, Intermediate, Advanced)
- Navigation to test info screen

### 2. `skill_test_info.dart` - Test Information
- Shows detailed test information and instructions
- Displays test overview with icon, title, and details
- Lists test instructions and rules
- "Start Test" button that navigates to the actual test

### 3. `skills_test_faq.dart` - Test Questions (NEW)
- Displays multiple choice questions for the skill test
- Features a countdown timer (15 minutes default)
- Shows test provider information with logo
- Grid layout for answer options (2x2 grid)
- Submit button appears when all questions are answered
- Automatically navigates to results page on completion

### 4. `test_results.dart` - Test Results (NEW)
- Shows test performance with correct/wrong answers
- Displays percentage score and performance message
- Performance-based feedback and encouragement
- "Back To Home" button for navigation

## Flow

1. **Skill Test List** → User selects a test
2. **Test Info** → User reads instructions and starts test
3. **Test Questions** → User answers MCQs with timer
4. **Test Results** → User sees performance and navigates home

## Features

### Timer Functionality
- 15-minute countdown timer
- Auto-submits when time expires
- Visual timer display in header

### Question Management
- Multiple choice questions with 4 options each
- Grid layout for answer selection
- Visual feedback for selected answers
- Submit button only enabled when all questions answered

### Results Calculation
- Automatic scoring based on selected answers
- Performance categorization (Excellent, Good, Average, Need Improvement)
- Personalized feedback messages
- Percentage calculation

### Navigation
- Integrated with app's navigation system
- Proper back button handling
- Route-based navigation for deep linking

## Usage

### Starting a Test
```dart
NavigationService.navigateTo(
  SkillsTestFAQScreen(job: jobData, test: testData),
);
```

### Viewing Results
```dart
NavigationService.navigateTo(
  TestResultsScreen(
    correctAnswers: 12,
    wrongAnswers: 2,
    totalQuestions: 14,
  ),
);
```

## Customization

### Adding New Questions
Modify the `_questions` list in `skills_test_faq.dart`:

```dart
final List<Map<String, dynamic>> _questions = [
  {
    'question': 'Your question here?',
    'options': [
      'Option 1',
      'Option 2', 
      'Option 3',
      'Option 4',
    ],
  },
  // Add more questions...
];
```

### Changing Timer Duration
Modify the `_remainingTime` variable in `skills_test_faq.dart`:

```dart
int _remainingTime = 20 * 60; // 20 minutes
```

### Customizing Performance Messages
Modify the `_getFeedbackMessage` method in `test_results.dart` to change feedback text.

## Integration

These pages are fully integrated with the existing app:
- Use app constants for consistent styling
- Follow app navigation patterns
- Maintain consistent UI/UX design
- Support both English and Hindi text

