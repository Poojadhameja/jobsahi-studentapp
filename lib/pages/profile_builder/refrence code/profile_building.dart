import 'package:flutter/material.dart';
import '../../../../../../utils/app_constants.dart';
import '../../../../../../utils/navigation_service.dart';
import '../../../../../home/home.dart';

/// ---------------- SCREEN 1: JOB TYPE SELECTION ----------------
class JobTypeScreen extends StatefulWidget {
  const JobTypeScreen({super.key});

  @override
  State<JobTypeScreen> createState() => _JobTypeScreenState();
}

class _JobTypeScreenState extends State<JobTypeScreen> {
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
            color: isSelected ? AppConstants.accentColor : AppConstants.borderColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          color: isSelected ? AppConstants.accentColor.withValues(alpha: 0.1) : AppConstants.cardBackgroundColor,
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
            colors: [AppConstants.primaryColor, Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.smallPadding + 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  StepCircle(number: 1, isFilled: true),
                  StepLine(isFilled: true),
                  StepCircle(number: 2, isFilled: false),
                  StepLine(isFilled: false),
                  StepCircle(number: 3, isFilled: false),
                ],
              ),

              const SizedBox(height: AppConstants.defaultPadding + 4),

              Expanded(
                child: Container(
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
                      Text(
                        "Which type of job are you\nlooking for?",
                        textAlign: TextAlign.center,
                        style: AppConstants.headingStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),

                      Text(
                        "नीचे से एक विकल्प चुनें",
                        textAlign: TextAlign.center,
                        style: AppConstants.captionStyle.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: AppConstants.largePadding),

                      customOption("Full Time"),
                      customOption("Apprenticeship"),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: selectedOption != null
                            ? () {
                                NavigationService.navigateTo(
                                  const ExperienceLevelScreen(),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          ),
                        ),
                        child: Text(
                          AppConstants.nextButton,
                          style: AppConstants.buttonTextStyle,
                        ),
                      )
                    ],
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

/// ---------------- SCREEN 2: EXPERIENCE LEVEL SELECTION ----------------
class ExperienceLevelScreen extends StatefulWidget {
  const ExperienceLevelScreen({super.key});

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
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
            color: isSelected ? AppConstants.accentColor : AppConstants.borderColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          color: isSelected ? AppConstants.accentColor.withValues(alpha: 0.1) : AppConstants.cardBackgroundColor,
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
            colors: [AppConstants.primaryColor, Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.smallPadding + 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  StepCircle(number: 1, isFilled: true),
                  StepLine(isFilled: true),
                  StepCircle(number: 2, isFilled: true),
                  StepLine(isFilled: true),
                  StepCircle(number: 3, isFilled: false),
                ],
              ),

              const SizedBox(height: AppConstants.defaultPadding + 4),

              Expanded(
                child: Container(
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
                      Text(
                        "What is your current\nexperience level?",
                        textAlign: TextAlign.center,
                        style: AppConstants.headingStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),

                      Text(
                        "नीचे से सही विकल्प चुनें",
                        textAlign: TextAlign.center,
                        style: AppConstants.captionStyle.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: AppConstants.largePadding),

                      customOption("Fresher"),
                      customOption("Poly"),
                      customOption("Other"),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: selectedOption != null
                            ? () {
                                NavigationService.navigateTo(
                                  const TradeSelectionScreen(),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          ),
                        ),
                        child: Text(
                          AppConstants.nextButton,
                          style: AppConstants.buttonTextStyle,
                        ),
                      )
                    ],
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

/// ---------------- SCREEN 3: TRADE SELECTION ----------------
class TradeSelectionScreen extends StatefulWidget {
  const TradeSelectionScreen({super.key});

  @override
  State<TradeSelectionScreen> createState() => _TradeSelectionScreenState();
}

class _TradeSelectionScreenState extends State<TradeSelectionScreen> {
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
            colors: [AppConstants.primaryColor, Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.defaultPadding),

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

              const SizedBox(height: AppConstants.defaultPadding),

              Expanded(
                child: Container(
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
                    children: [
                      Text(
                        'What trade are you\nlooking to obtain?',
                        textAlign: TextAlign.center,
                        style: AppConstants.headingStyle.copyWith(fontSize: 20),
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
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppConstants.accentColor.withValues(alpha: 0.1)
                                      : AppConstants.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppConstants.accentColor
                                        : AppConstants.borderColor.withValues(alpha: 0.3),
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
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      activeColor: AppConstants.accentColor,
                                    ),
                                    const SizedBox(width: AppConstants.smallPadding),

                                    Expanded(
                                      child: Text(
                                        trade,
                                        style: AppConstants.bodyStyle,
                                      ),
                                    )
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
                            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          ),
                        ),
                        onPressed: () {
                          NavigationService.navigateTo(
                            const ConnectPage(),
                          );
                        },
                        child: Text(
                          AppConstants.nextButton,
                          style: AppConstants.buttonTextStyle.copyWith(fontSize: 18),
                        ),
                      )
                    ],
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

/// ---------------- FINAL CONNECT PAGE ----------------
class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppConstants.primaryColor, Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppConstants.successColor,
                  size: 80,
                ),
                const SizedBox(height: 20),

                Text(
                  'Successfully Connected!',
                  style: AppConstants.headingStyle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 10),

                Text(
                  'Your job preferences have been saved',
                  style: AppConstants.captionStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    NavigationService.navigateToAndClear(const HomeScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    ),
                  ),
                  child: Text(
                    'Go to Home',
                    style: AppConstants.buttonTextStyle,
                  ),
                ),
              ],
            ),
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
          color: isFilled ? AppConstants.accentColor : AppConstants.textSecondaryColor,
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
      color: isFilled ? AppConstants.accentColor : AppConstants.borderColor.withValues(alpha: 0.4),
    );
  }
}
