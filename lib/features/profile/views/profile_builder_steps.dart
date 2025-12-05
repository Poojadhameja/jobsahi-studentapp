/// Profile Builder Steps - Optimized with Reusable Components
/// Three step-based pages for profile building after authentication
/// All repetitive tasks are now handled by reusable components

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

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
            onPressed: () => context.pop(),
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
class ProfileBuilderStep1Screen extends StatelessWidget {
  const ProfileBuilderStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: const _ProfileBuilderStep1View(),
    );
  }
}

class _ProfileBuilderStep1View extends StatelessWidget {
  const _ProfileBuilderStep1View();

  void onOptionSelected(BuildContext context, String value) {
    context.read<ProfileBloc>().add(UpdateJobTypeEvent(jobType: value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? selectedOption;
        if (state is ProfileBuilderState) {
          selectedOption = state.selectedJobType;
        }

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
                              onTap: () => onOptionSelected(context, "Full Time"),
                            ),
                            OptionBuilder(
                              value: "Apprenticeship",
                              isSelected: selectedOption == "Apprenticeship",
                              onTap: () => onOptionSelected(context, "Apprenticeship"),
                            ),
                            const Spacer(),
                          ],
                        ),
                        actions: NextButton(
                          onPressed: selectedOption != null
                              ? () {
                                  context.go(
                                    '${AppRoutes.profileBuilderStep2}?selectedJobType=${Uri.encodeComponent(selectedOption!)}',
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
      },
    );
  }
}

/// Step 2: Experience Level Selection
class ProfileBuilderStep2Screen extends StatelessWidget {
  final String selectedJobType;

  const ProfileBuilderStep2Screen({super.key, required this.selectedJobType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(UpdateJobTypeEvent(jobType: selectedJobType)),
      child: _ProfileBuilderStep2View(selectedJobType: selectedJobType),
    );
  }
}

class _ProfileBuilderStep2View extends StatelessWidget {
  final String selectedJobType;

  const _ProfileBuilderStep2View({required this.selectedJobType});

  void onOptionSelected(BuildContext context, String value) {
    context.read<ProfileBloc>().add(UpdateExperienceLevelEvent(experienceLevel: value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? selectedOption;
        if (state is ProfileBuilderState) {
          selectedOption = state.selectedExperienceLevel;
        }

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
                              onTap: () => onOptionSelected(context, "Fresher"),
                            ),
                            OptionBuilder(
                              value: "Experienced",
                              isSelected: selectedOption == "Experienced",
                              onTap: () => onOptionSelected(context, "Experienced"),
                            ),
                            OptionBuilder(
                              value: "Other",
                              isSelected: selectedOption == "Other",
                              onTap: () => onOptionSelected(context, "Other"),
                            ),
                            const Spacer(),
                          ],
                        ),
                        actions: NextButton(
                          onPressed: selectedOption != null
                              ? () {
                                  context.go(
                                    '${AppRoutes.profileBuilderStep3}?selectedJobType=${Uri.encodeComponent(selectedJobType)}&selectedExperienceLevel=${Uri.encodeComponent(selectedOption!)}',
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
      },
    );
  }
}

/// Step 3: Trade Selection
class ProfileBuilderStep3Screen extends StatelessWidget {
  final String selectedJobType;
  final String selectedExperienceLevel;

  const ProfileBuilderStep3Screen({
    super.key,
    required this.selectedJobType,
    required this.selectedExperienceLevel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()
        ..add(UpdateJobTypeEvent(jobType: selectedJobType))
        ..add(UpdateExperienceLevelEvent(experienceLevel: selectedExperienceLevel)),
      child: _ProfileBuilderStep3View(
        selectedJobType: selectedJobType,
        selectedExperienceLevel: selectedExperienceLevel,
      ),
    );
  }
}

class _ProfileBuilderStep3View extends StatelessWidget {
  final String selectedJobType;
  final String selectedExperienceLevel;

  const _ProfileBuilderStep3View({
    required this.selectedJobType,
    required this.selectedExperienceLevel,
  });

  void onOptionSelected(BuildContext context, String value) {
    context.read<ProfileBloc>().add(UpdatePreferredLocationEvent(preferredLocation: value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? selectedOption;
        if (state is ProfileBuilderState) {
          selectedOption = state.selectedPreferredLocation;
        }

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
                                onTap: () => onOptionSelected(context, "Computer Science"),
                              ),
                              OptionBuilder(
                                value: "COPA",
                                isSelected: selectedOption == "COPA",
                                onTap: () => onOptionSelected(context, "COPA"),
                              ),
                              OptionBuilder(
                                value: "Diesel Mechanic",
                                isSelected: selectedOption == "Diesel Mechanic",
                                onTap: () => onOptionSelected(context, "Diesel Mechanic"),
                              ),
                              OptionBuilder(
                                value: "Mining",
                                isSelected: selectedOption == "Mining",
                                onTap: () => onOptionSelected(context, "Mining"),
                              ),
                              OptionBuilder(
                                value: "Mechanical",
                                isSelected: selectedOption == "Mechanical",
                                onTap: () => onOptionSelected(context, "Mechanical"),
                              ),
                              OptionBuilder(
                                value: "Fitter",
                                isSelected: selectedOption == "Fitter",
                                onTap: () => onOptionSelected(context, "Fitter"),
                              ),
                              OptionBuilder(
                                value: "Electrical",
                                isSelected: selectedOption == "Electrical",
                                onTap: () => onOptionSelected(context, "Electrical"),
                              ),
                              OptionBuilder(
                                value: "Electrician",
                                isSelected: selectedOption == "Electrician",
                                onTap: () => onOptionSelected(context, "Electrician"),
                              ),
                              OptionBuilder(
                                value: "Civil",
                                isSelected: selectedOption == "Civil",
                                onTap: () => onOptionSelected(context, "Civil"),
                              ),
                              OptionBuilder(
                                value: "On Demand",
                                isSelected: selectedOption == "On Demand",
                                onTap: () => onOptionSelected(context, "On Demand"),
                              ),
                            ],
                          ),
                        ),
                        actions: NextButton(
                          onPressed: selectedOption != null
                              ? () {
                                  context.go(AppRoutes.yourLocation);
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
      },
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
