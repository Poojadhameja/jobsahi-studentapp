/// Profile Builder Steps - Optimized with Reusable Components
/// Three step-based pages for profile building after authentication
/// All repetitive tasks are now handled by reusable components

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';

/// Reusable Background Layer Components
class BackgroundLayers extends StatelessWidget {
  final Widget child;

  const BackgroundLayers({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background card 3 (furthest back)
        Positioned(
          top: 3,
          left: 37,
          right: 37,
          bottom: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(
                AppConstants.largeBorderRadius + 4,
              ),
            ),
          ),
        ),
        // Background card 2 (middle layer)
        Positioned(
          top: 10,
          left: 27,
          right: 27,
          bottom: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                AppConstants.largeBorderRadius + 2,
              ),
            ),
          ),
        ),
        // Main white card (foreground)
        child,
      ],
    );
  }
}

/// Reusable Header Component
class ProfileBuilderHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProfileBuilderHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => NavigationService.goBack(),
          ),
          const Spacer(),

          // Progress indicator
          _buildProgressIndicator(),

          const Spacer(),

          // Empty space to balance the layout
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isFilled = stepNumber <= currentStep;

        return Row(
          children: [
            StepCircle(number: stepNumber, isFilled: isFilled),
            if (stepNumber < totalSteps)
              StepLine(isFilled: stepNumber < currentStep),
          ],
        );
      }),
    );
  }
}

/// Reusable Main Card Container
class MainCardContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final Widget? actions;

  const MainCardContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding + 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding + 4,
        vertical: AppConstants.largePadding + 6,
      ),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppConstants.headingStyle.copyWith(fontSize: 20),
          ),

          const SizedBox(height: AppConstants.smallPadding),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppConstants.captionStyle.copyWith(fontSize: 14),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Content
          Expanded(child: content),

          // Actions (if any)
          if (actions != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            actions!,
          ],
        ],
      ),
    );
  }
}

/// Reusable Option Builder
class OptionBuilder extends StatelessWidget {
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionBuilder({
    super.key,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              onChanged: (_) => onTap(),
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
}

/// Reusable Next Button
class NextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const NextButton({
    super.key,
    required this.onPressed,
    this.text = AppConstants.nextButton,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.secondaryColor,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
      ),
      child: Text(text, style: AppConstants.buttonTextStyle),
    );
  }
}

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

              // Header
              const ProfileBuilderHeader(currentStep: 1, totalSteps: 3),

              const SizedBox(height: AppConstants.defaultPadding + 4),

              // Main content
              Expanded(
                child: BackgroundLayers(
                  child: MainCardContainer(
                    title: "Which type of job are you\nlooking for?",
                    subtitle: "नीचे से एक विकल्प चुनें",
                    content: Column(
                      children: [
                        OptionBuilder(
                          value: "Full Time",
                          isSelected: selectedOption == "Full Time",
                          onTap: () => onOptionSelected("Full Time"),
                        ),
                        OptionBuilder(
                          value: "Apprenticeship",
                          isSelected: selectedOption == "Apprenticeship",
                          onTap: () => onOptionSelected("Apprenticeship"),
                        ),
                        const Spacer(),
                      ],
                    ),
                    actions: NextButton(
                      onPressed: selectedOption != null
                          ? () {
                              NavigationService.smartNavigate(
                                destination: ProfileBuilderStep2Screen(
                                  selectedJobType: selectedOption!,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
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

              // Header
              const ProfileBuilderHeader(currentStep: 2, totalSteps: 3),

              const SizedBox(height: AppConstants.defaultPadding + 4),

              // Main content
              Expanded(
                child: BackgroundLayers(
                  child: MainCardContainer(
                    title: "What is your current\nexperience level?",
                    subtitle: "नीचे से सही विकल्प चुनें",
                    content: Column(
                      children: [
                        OptionBuilder(
                          value: "Fresher",
                          isSelected: selectedOption == "Fresher",
                          onTap: () => onOptionSelected("Fresher"),
                        ),
                        OptionBuilder(
                          value: "Experienced",
                          isSelected: selectedOption == "Experienced",
                          onTap: () => onOptionSelected("Experienced"),
                        ),
                        OptionBuilder(
                          value: "Other",
                          isSelected: selectedOption == "Other",
                          onTap: () => onOptionSelected("Other"),
                        ),
                        const Spacer(),
                      ],
                    ),
                    actions: NextButton(
                      onPressed: selectedOption != null
                          ? () {
                              NavigationService.smartNavigate(
                                destination: ProfileBuilderStep3Screen(
                                  selectedJobType: widget.selectedJobType,
                                  selectedExperienceLevel: selectedOption!,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
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
  String? selectedOption;

  void onOptionSelected(String value) {
    setState(() {
      selectedOption = value;
    });
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

              // Header
              const ProfileBuilderHeader(currentStep: 3, totalSteps: 3),

              const SizedBox(height: AppConstants.defaultPadding + 4),

              // Main content
              Expanded(
                child: BackgroundLayers(
                  child: MainCardContainer(
                    title: "What trade are you\nlooking to obtain?",
                    subtitle: "नीचे से सही विकल्प चुनें",
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          OptionBuilder(
                            value: "Computer Science",
                            isSelected: selectedOption == "Computer Science",
                            onTap: () => onOptionSelected("Computer Science"),
                          ),
                          OptionBuilder(
                            value: "COPA",
                            isSelected: selectedOption == "COPA",
                            onTap: () => onOptionSelected("COPA"),
                          ),
                          OptionBuilder(
                            value: "Diesel Mechanic",
                            isSelected: selectedOption == "Diesel Mechanic",
                            onTap: () => onOptionSelected("Diesel Mechanic"),
                          ),
                          OptionBuilder(
                            value: "Mining",
                            isSelected: selectedOption == "Mining",
                            onTap: () => onOptionSelected("Mining"),
                          ),
                          OptionBuilder(
                            value: "Mechanical",
                            isSelected: selectedOption == "Mechanical",
                            onTap: () => onOptionSelected("Mechanical"),
                          ),
                          OptionBuilder(
                            value: "Fitter",
                            isSelected: selectedOption == "Fitter",
                            onTap: () => onOptionSelected("Fitter"),
                          ),
                          OptionBuilder(
                            value: "Electrical",
                            isSelected: selectedOption == "Electrical",
                            onTap: () => onOptionSelected("Electrical"),
                          ),
                          OptionBuilder(
                            value: "Electrician",
                            isSelected: selectedOption == "Electrician",
                            onTap: () => onOptionSelected("Electrician"),
                          ),
                          OptionBuilder(
                            value: "Civil",
                            isSelected: selectedOption == "Civil",
                            onTap: () => onOptionSelected("Civil"),
                          ),
                          OptionBuilder(
                            value: "On Demand",
                            isSelected: selectedOption == "On Demand",
                            onTap: () => onOptionSelected("On Demand"),
                          ),
                        ],
                      ),
                    ),
                    actions: NextButton(
                      onPressed: selectedOption != null
                          ? () {
                              NavigationService.smartNavigate(
                                routeName: RouteNames.location1,
                              );
                            }
                          : null,
                    ),
                  ),
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
      backgroundColor: isFilled
          ? AppConstants.successColor
          : AppConstants.accentColor,
      child: Text(
        "$number",
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
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
          ? AppConstants.successColor
          : AppConstants.borderColor.withValues(alpha: 0.4),
    );
  }
}
