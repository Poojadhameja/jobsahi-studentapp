/// Profile Builder Steps
/// Three step-based pages for profile building after authentication
/// This file contains all three steps in one file as requested
/// Design matches the reference code exactly

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';

/// Step 1: Job Type Selection
class ProfileBuilderStep1Screen extends StatefulWidget {
  const ProfileBuilderStep1Screen({super.key});

  @override
  State<ProfileBuilderStep1Screen> createState() =>
      _ProfileBuilderStep1ScreenState();
}

class _ProfileBuilderStep1ScreenState extends State<ProfileBuilderStep1Screen> {
  String? selectedOption;

  void onOptionSelected(String value) {
    setState(() {
      selectedOption = value;
    });
  }

  Widget customOption(String value) {
    final isSelected = selectedOption == value;
    return GestureDetector(
      onTap: () => onOptionSelected(value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding + 4,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppConstants.accentColor
                : AppConstants.borderColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          color: isSelected
              ? AppConstants.accentColor.withValues(alpha: 0.1)
              : AppConstants.cardBackgroundColor,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onOptionSelected(value),
              activeColor: AppConstants.accentColor,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.bodyStyle.fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B537D), Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.smallPadding + 4),

              // Back button and progress indicator row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => NavigationService.goBack(),
                    ),
                    const Spacer(),
                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        StepCircle(number: 1, isFilled: true),
                        StepLine(isFilled: false),
                        StepCircle(number: 2, isFilled: false),
                        StepLine(isFilled: false),
                        StepCircle(number: 3, isFilled: false),
                      ],
                    ),
                    const Spacer(),
                    // Empty space to balance the layout
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding + 4),

              Expanded(
                child: Stack(
                  children: [
                    // Background card 3 (furthest back)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            AppConstants.largeBorderRadius + 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Background card 2 (middle layer)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            AppConstants.largeBorderRadius + 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Main white card (foreground)
                    Container(
                      margin: const EdgeInsets.all(
                        AppConstants.defaultPadding + 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding + 4,
                        vertical: AppConstants.largePadding + 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.largeBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Which type of job are you\nlooking for?",
                            textAlign: TextAlign.center,
                            style: AppConstants.headingStyle.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallPadding),

                          Text(
                            "नीचे से एक विकल्प चुनें",
                            textAlign: TextAlign.center,
                            style: AppConstants.captionStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppConstants.largePadding),

                          customOption("Full Time"),
                          customOption("Apprenticeship"),

                          const Spacer(),

                          ElevatedButton(
                            onPressed: selectedOption != null
                                ? () {
                                    NavigationService.smartNavigate(
                                      destination: ProfileBuilderStep2Screen(
                                        selectedJobType: selectedOption!,
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.defaultPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.smallBorderRadius,
                                ),
                              ),
                            ),
                            child: Text(
                              AppConstants.nextButton,
                              style: AppConstants.buttonTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 2: Experience Level Selection
class ProfileBuilderStep2Screen extends StatefulWidget {
  final String selectedJobType;

  const ProfileBuilderStep2Screen({super.key, required this.selectedJobType});

  @override
  State<ProfileBuilderStep2Screen> createState() =>
      _ProfileBuilderStep2ScreenState();
}

class _ProfileBuilderStep2ScreenState extends State<ProfileBuilderStep2Screen> {
  String? selectedOption;

  void onOptionSelected(String value) {
    setState(() {
      selectedOption = value;
    });
  }

  Widget customOption(String value) {
    final isSelected = selectedOption == value;
    return GestureDetector(
      onTap: () => onOptionSelected(value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding + 4,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppConstants.accentColor
                : AppConstants.borderColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          color: isSelected
              ? AppConstants.accentColor.withValues(alpha: 0.1)
              : AppConstants.cardBackgroundColor,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onOptionSelected(value),
              activeColor: AppConstants.accentColor,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.bodyStyle.fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B537D), Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.smallPadding + 4),

              // Back button and progress indicator row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => NavigationService.goBack(),
                    ),
                    const Spacer(),
                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        StepCircle(number: 1, isFilled: true),
                        StepLine(isFilled: true),
                        StepCircle(number: 2, isFilled: true),
                        StepLine(isFilled: false),
                        StepCircle(number: 3, isFilled: false),
                      ],
                    ),
                    const Spacer(),
                    // Empty space to balance the layout
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding + 4),

              Expanded(
                child: Stack(
                  children: [
                    // Background card 3 (furthest back)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            AppConstants.largeBorderRadius + 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Background card 2 (middle layer)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            AppConstants.largeBorderRadius + 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Main white card (foreground)
                    Container(
                      margin: const EdgeInsets.all(
                        AppConstants.defaultPadding + 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding + 4,
                        vertical: AppConstants.largePadding + 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.largeBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "What is your current\nexperience level?",
                            textAlign: TextAlign.center,
                            style: AppConstants.headingStyle.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallPadding),

                          Text(
                            "नीचे से सही विकल्प चुनें",
                            textAlign: TextAlign.center,
                            style: AppConstants.captionStyle.copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: AppConstants.largePadding),

                          customOption("Fresher"),
                          customOption("Experienced"),
                          customOption("Other"),

                          const Spacer(),

                          ElevatedButton(
                            onPressed: selectedOption != null
                                ? () {
                                    NavigationService.smartNavigate(
                                      destination: ProfileBuilderStep3Screen(
                                        selectedJobType: widget.selectedJobType,
                                        selectedExperienceLevel:
                                            selectedOption!,
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.defaultPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.smallBorderRadius,
                                ),
                              ),
                            ),
                            child: Text(
                              AppConstants.nextButton,
                              style: AppConstants.buttonTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 3: Trade Selection
class ProfileBuilderStep3Screen extends StatefulWidget {
  final String selectedJobType;
  final String selectedExperienceLevel;

  const ProfileBuilderStep3Screen({
    super.key,
    required this.selectedJobType,
    required this.selectedExperienceLevel,
  });

  @override
  State<ProfileBuilderStep3Screen> createState() =>
      _ProfileBuilderStep3ScreenState();
}

class _ProfileBuilderStep3ScreenState extends State<ProfileBuilderStep3Screen> {
  final List<String> trades = [
    'Computer Science',
    'COPA',
    'Diesel Mechanic',
    'Mining',
    'Mechanical',
    'Fitter',
    'Electrical',
    'Electrician',
    'Civil',
    'On Demand',
  ];

  String? selectedTrade = 'Computer Science';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B537D), Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.defaultPadding),

              // Back button and progress indicator row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => NavigationService.goBack(),
                    ),
                    const Spacer(),
                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        StepCircle(number: 1, isFilled: true),
                        StepLine(isFilled: true),
                        StepCircle(number: 2, isFilled: true),
                        StepLine(isFilled: true),
                        StepCircle(number: 3, isFilled: true),
                      ],
                    ),
                    const Spacer(),
                    // Empty space to balance the layout
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              Expanded(
                child: Stack(
                  children: [
                    // Background card 3 (furthest back)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            AppConstants.largeBorderRadius + 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Background card 2 (middle layer)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            AppConstants.largeBorderRadius + 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Main white card (foreground)
                    Container(
                      margin: const EdgeInsets.all(
                        AppConstants.defaultPadding + 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding + 4,
                        vertical: AppConstants.largePadding + 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.largeBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'What trade are you\nlooking to obtain?',
                            textAlign: TextAlign.center,
                            style: AppConstants.headingStyle.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            'नीचे से सही विकल्प चुनें',
                            style: AppConstants.captionStyle,
                          ),
                          const SizedBox(height: 20),

                          Expanded(
                            child: ListView.builder(
                              itemCount: trades.length,
                              itemBuilder: (context, index) {
                                String trade = trades[index];
                                bool isSelected = selectedTrade == trade;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTrade = trade;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppConstants.accentColor.withValues(
                                              alpha: 0.1,
                                            )
                                          : AppConstants.cardBackgroundColor,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppConstants.accentColor
                                            : AppConstants.borderColor
                                                  .withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) {
                                            setState(() {
                                              selectedTrade = trade;
                                            });
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          activeColor: AppConstants.accentColor,
                                        ),
                                        const SizedBox(
                                          width: AppConstants.smallPadding,
                                        ),

                                        Expanded(
                                          child: Text(
                                            trade,
                                            style: AppConstants.bodyStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.smallBorderRadius,
                                ),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to location flow
                              NavigationService.smartNavigate(
                                routeName: RouteNames.location1,
                              );
                            },
                            child: Text(
                              AppConstants.nextButton,
                              style: AppConstants.buttonTextStyle.copyWith(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- COMMON STEPPER COMPONENTS ----------------
class StepCircle extends StatelessWidget {
  final int number;
  final bool isFilled;

  const StepCircle({super.key, required this.number, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: AppConstants.cardBackgroundColor,
      child: Text(
        "$number",
        style: TextStyle(
          fontSize: 16,
          color: isFilled
              ? AppConstants.accentColor
              : AppConstants.textSecondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class StepLine extends StatelessWidget {
  final bool isFilled;

  const StepLine({super.key, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      color: isFilled
          ? AppConstants.accentColor
          : AppConstants.borderColor.withValues(alpha: 0.4),
    );
  }
}
