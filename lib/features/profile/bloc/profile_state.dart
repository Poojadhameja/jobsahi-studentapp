import 'package:equatable/equatable.dart';

/// Profile states
abstract class ProfileState extends Equatable {
  const ProfileState();
}

/// Initial profile state
class ProfileInitial extends ProfileState {
  const ProfileInitial();

  @override
  List<Object?> get props => [];
}

/// Profile loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();

  @override
  List<Object?> get props => [];
}

/// Profile loaded state
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userProfile;
  final List<String> skills;
  final List<Map<String, dynamic>> education;
  final List<Map<String, dynamic>> experience;
  final Map<String, dynamic> jobPreferences;

  const ProfileLoaded({
    required this.userProfile,
    required this.skills,
    required this.education,
    required this.experience,
    required this.jobPreferences,
  });

  @override
  List<Object?> get props => [
    userProfile,
    skills,
    education,
    experience,
    jobPreferences,
  ];

  /// Copy with method for immutable state updates
  ProfileLoaded copyWith({
    Map<String, dynamic>? userProfile,
    List<String>? skills,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? experience,
    Map<String, dynamic>? jobPreferences,
  }) {
    return ProfileLoaded(
      userProfile: userProfile ?? this.userProfile,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      jobPreferences: jobPreferences ?? this.jobPreferences,
    );
  }
}

/// Profile error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile update success state
class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile image update success state
class ProfileImageUpdateSuccess extends ProfileState {
  final String imagePath;

  const ProfileImageUpdateSuccess({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// Skills update success state
class SkillsUpdateSuccess extends ProfileState {
  final List<String> skills;

  const SkillsUpdateSuccess({required this.skills});

  @override
  List<Object?> get props => [skills];
}

/// Education update success state
class EducationUpdateSuccess extends ProfileState {
  final String message;

  const EducationUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Experience update success state
class ExperienceUpdateSuccess extends ProfileState {
  final String message;

  const ExperienceUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Job preferences update success state
class JobPreferencesUpdateSuccess extends ProfileState {
  final String message;

  const JobPreferencesUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile details loaded state
class ProfileDetailsLoaded extends ProfileState {
  final Map<String, dynamic> userProfile;
  final List<String> skills;
  final List<Map<String, dynamic>> education;
  final List<Map<String, dynamic>> experience;
  final Map<String, dynamic> jobPreferences;
  final Map<String, bool> sectionExpansionStates;
  final List<Map<String, dynamic>> certificates;
  final String? profileImagePath;
  final String? profileImageName;
  final String? resumeFileName;
  final String? lastResumeUpdatedDate;
  final int resumeFileSize;

  const ProfileDetailsLoaded({
    required this.userProfile,
    required this.skills,
    required this.education,
    required this.experience,
    required this.jobPreferences,
    required this.sectionExpansionStates,
    required this.certificates,
    this.profileImagePath,
    this.profileImageName,
    this.resumeFileName,
    this.lastResumeUpdatedDate,
    required this.resumeFileSize,
  });

  @override
  List<Object?> get props => [
    userProfile,
    skills,
    education,
    experience,
    jobPreferences,
    sectionExpansionStates,
    certificates,
    profileImagePath,
    profileImageName,
    resumeFileName,
    lastResumeUpdatedDate,
    resumeFileSize,
  ];

  /// Copy with method for immutable state updates
  ProfileDetailsLoaded copyWith({
    Map<String, dynamic>? userProfile,
    List<String>? skills,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? experience,
    Map<String, dynamic>? jobPreferences,
    Map<String, bool>? sectionExpansionStates,
    List<Map<String, dynamic>>? certificates,
    String? profileImagePath,
    String? profileImageName,
    String? resumeFileName,
    String? lastResumeUpdatedDate,
    int? resumeFileSize,
  }) {
    return ProfileDetailsLoaded(
      userProfile: userProfile ?? this.userProfile,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      jobPreferences: jobPreferences ?? this.jobPreferences,
      sectionExpansionStates:
          sectionExpansionStates ?? this.sectionExpansionStates,
      certificates: certificates ?? this.certificates,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      profileImageName: profileImageName ?? this.profileImageName,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      lastResumeUpdatedDate:
          lastResumeUpdatedDate ?? this.lastResumeUpdatedDate,
      resumeFileSize: resumeFileSize ?? this.resumeFileSize,
    );
  }
}

/// Certificate deleted success state
class CertificateDeletedSuccess extends ProfileState {
  final String message;

  const CertificateDeletedSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile image removed success state
class ProfileImageRemovedSuccess extends ProfileState {
  const ProfileImageRemovedSuccess();

  @override
  List<Object?> get props => [];
}

/// Profile builder state
class ProfileBuilderState extends ProfileState {
  final String? selectedJobType;
  final String? selectedExperienceLevel;
  final String? selectedPreferredLocation;

  const ProfileBuilderState({
    this.selectedJobType,
    this.selectedExperienceLevel,
    this.selectedPreferredLocation,
  });

  @override
  List<Object?> get props => [
    selectedJobType,
    selectedExperienceLevel,
    selectedPreferredLocation,
  ];

  /// Copy with method for immutable state updates
  ProfileBuilderState copyWith({
    String? selectedJobType,
    String? selectedExperienceLevel,
    String? selectedPreferredLocation,
  }) {
    return ProfileBuilderState(
      selectedJobType: selectedJobType ?? this.selectedJobType,
      selectedExperienceLevel:
          selectedExperienceLevel ?? this.selectedExperienceLevel,
      selectedPreferredLocation:
          selectedPreferredLocation ?? this.selectedPreferredLocation,
    );
  }
}

/// Personalize jobfeed state
class PersonalizeJobfeedState extends ProfileState {
  final String? selectedTrade;
  final String? selectedState;
  final String? selectedCity;
  final String? selectedSalaryRange;
  final String availability;
  final List<String> selectedSectors;
  final List<String> selectedJobTypes;
  final List<String> skills;

  const PersonalizeJobfeedState({
    this.selectedTrade,
    this.selectedState,
    this.selectedCity,
    this.selectedSalaryRange,
    required this.availability,
    required this.selectedSectors,
    required this.selectedJobTypes,
    required this.skills,
  });

  @override
  List<Object?> get props => [
    selectedTrade,
    selectedState,
    selectedCity,
    selectedSalaryRange,
    availability,
    selectedSectors,
    selectedJobTypes,
    skills,
  ];

  /// Copy with method for immutable state updates
  PersonalizeJobfeedState copyWith({
    String? selectedTrade,
    String? selectedState,
    String? selectedCity,
    String? selectedSalaryRange,
    String? availability,
    List<String>? selectedSectors,
    List<String>? selectedJobTypes,
    List<String>? skills,
  }) {
    return PersonalizeJobfeedState(
      selectedTrade: selectedTrade ?? this.selectedTrade,
      selectedState: selectedState ?? this.selectedState,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedSalaryRange: selectedSalaryRange ?? this.selectedSalaryRange,
      availability: availability ?? this.availability,
      selectedSectors: selectedSectors ?? this.selectedSectors,
      selectedJobTypes: selectedJobTypes ?? this.selectedJobTypes,
      skills: skills ?? this.skills,
    );
  }
}

/// Location state
class LocationState extends ProfileState {
  final String? selectedLocation;
  final String searchQuery;
  final List<Map<String, String>> locations;

  const LocationState({
    this.selectedLocation,
    required this.searchQuery,
    required this.locations,
  });

  @override
  List<Object?> get props => [selectedLocation, searchQuery, locations];

  /// Filtered locations based on search
  List<Map<String, String>> get filteredLocations {
    if (searchQuery.isEmpty) {
      return locations;
    }
    return locations.where((location) {
      return location['name']!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          location['address']!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
    }).toList();
  }

  /// Copy with method for immutable state updates
  LocationState copyWith({
    String? selectedLocation,
    String? searchQuery,
    List<Map<String, String>>? locations,
  }) {
    return LocationState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      searchQuery: searchQuery ?? this.searchQuery,
      locations: locations ?? this.locations,
    );
  }
}

/// Location permission state
class LocationPermissionState extends ProfileState {
  final bool isProcessing;
  final bool permissionGranted;
  final bool permissionDenied;

  const LocationPermissionState({
    required this.isProcessing,
    required this.permissionGranted,
    required this.permissionDenied,
  });

  @override
  List<Object?> get props => [
    isProcessing,
    permissionGranted,
    permissionDenied,
  ];

  /// Copy with method for immutable state updates
  LocationPermissionState copyWith({
    bool? isProcessing,
    bool? permissionGranted,
    bool? permissionDenied,
  }) {
    return LocationPermissionState(
      isProcessing: isProcessing ?? this.isProcessing,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

/// Job status tab state
class JobStatusTabState extends ProfileState {
  final int selectedTabIndex;

  const JobStatusTabState({required this.selectedTabIndex});

  @override
  List<Object?> get props => [selectedTabIndex];

  JobStatusTabState copyWith({int? selectedTabIndex}) {
    return JobStatusTabState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

/// Profile edit form state
class ProfileEditFormState extends ProfileState {
  final String name;
  final String email;
  final String phone;
  final bool isSaving;

  const ProfileEditFormState({
    required this.name,
    required this.email,
    required this.phone,
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [name, email, phone, isSaving];

  ProfileEditFormState copyWith({
    String? name,
    String? email,
    String? phone,
    bool? isSaving,
  }) {
    return ProfileEditFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Profile changes saved state
class ProfileChangesSavedState extends ProfileState {
  const ProfileChangesSavedState();

  @override
  List<Object?> get props => [];
}

/// Skills edit form state
class SkillsEditFormState extends ProfileState {
  final List<String> skills;
  final bool isSaving;

  const SkillsEditFormState({required this.skills, this.isSaving = false});

  @override
  List<Object?> get props => [skills, isSaving];

  SkillsEditFormState copyWith({List<String>? skills, bool? isSaving}) {
    return SkillsEditFormState(
      skills: skills ?? this.skills,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Skills changes saved state
class SkillsChangesSavedState extends ProfileState {
  const SkillsChangesSavedState();

  @override
  List<Object?> get props => [];
}
