import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

/// PersonalizeJobfeedScreen - A screen for users to customize their job preferences
/// This screen allows users to set their trade, location, job sectors, job types,
/// availability, skills, and expected salary range for personalized job recommendations.
class PersonalizeJobfeedScreen extends StatelessWidget {
  const PersonalizeJobfeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfileDataEvent()),
      child: const _PersonalizeJobfeedView(),
    );
  }
}

class _PersonalizeJobfeedView extends StatefulWidget {
  const _PersonalizeJobfeedView();

  @override
  State<_PersonalizeJobfeedView> createState() =>
      _PersonalizeJobfeedViewState();
}

class _PersonalizeJobfeedViewState extends State<_PersonalizeJobfeedView> {
  /// Controller for adding new skills
  final TextEditingController skillsController = TextEditingController();

  // ===== JOB PREFERENCES LISTS =====

  /// Available job sectors for selection
  /// These are the different industry sectors where jobs are available
  List<String> jobSectors = [
    "Power Plant",
    "Manufacturing",
    "Construction",
    "Oil & Gas",
    "Mining",
    "Automotive",
    "Aerospace",
    "Telecommunications",
    "Healthcare",
    "Education",
  ];

  /// Available job types (Full Time, Part Time, Internship)
  List<String> jobTypes = [
    "Full Time",
    "Part Time",
    "Internship",
    "Contract",
    "Freelance",
    "Temporary",
  ];

  /// Available salary ranges from app constants
  List<String> salaryRanges = AppConstants.salaryRanges;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    context.read<ProfileBloc>().add(
      const UpdateSelectedTradeEvent(trade: "इलेक्ट्रीशियन"),
    );
    context.read<ProfileBloc>().add(
      const UpdateSelectedStateEvent(state: "Madhya Pradesh"),
    );
    context.read<ProfileBloc>().add(
      const UpdateSelectedCityEvent(city: "Balaghat"),
    );
    context.read<ProfileBloc>().add(
      const UpdateAvailabilityEvent(availability: "Immediately Available"),
    );

    // Initialize with default selected sectors and job types
    context.read<ProfileBloc>().add(
      const ToggleJobSectorEvent(sector: "Power Plant", isSelected: true),
    );
    context.read<ProfileBloc>().add(
      const ToggleJobTypeEvent(jobType: "Full Time", isSelected: true),
    );
    context.read<ProfileBloc>().add(
      const ToggleJobTypeEvent(jobType: "Internship", isSelected: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
          // ===== APP BAR =====
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Personalize Jobfeed",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          // ===== MAIN BODY CONTENT =====
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_outlined,
                  size: 80,
                  color: AppConstants.textSecondaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'We are working on this feature. It will be available soon!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
