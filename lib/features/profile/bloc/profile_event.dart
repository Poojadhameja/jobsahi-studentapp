import 'package:equatable/equatable.dart';

/// Profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

/// Load profile data event
class LoadProfileDataEvent extends ProfileEvent {
  const LoadProfileDataEvent();

  @override
  List<Object?> get props => [];
}

/// Update profile event
class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String bio;

  const UpdateProfileEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.bio,
  });

  @override
  List<Object?> get props => [name, email, phone, location, bio];
}

/// Update profile image event
class UpdateProfileImageEvent extends ProfileEvent {
  final String imagePath;

  const UpdateProfileImageEvent({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// Update job preferences event
class UpdateJobPreferencesEvent extends ProfileEvent {
  final List<String> preferredLocations;
  final List<String> preferredJobTypes;
  final String experienceLevel;
  final String salaryRange;

  const UpdateJobPreferencesEvent({
    required this.preferredLocations,
    required this.preferredJobTypes,
    required this.experienceLevel,
    required this.salaryRange,
  });

  @override
  List<Object?> get props => [
    preferredLocations,
    preferredJobTypes,
    experienceLevel,
    salaryRange,
  ];
}

/// Update skills event
class UpdateSkillsEvent extends ProfileEvent {
  final List<String> skills;

  const UpdateSkillsEvent({required this.skills});

  @override
  List<Object?> get props => [skills];
}

/// Update education event
class UpdateEducationEvent extends ProfileEvent {
  final String degree;
  final String institution;
  final String graduationYear;
  final String fieldOfStudy;

  const UpdateEducationEvent({
    required this.degree,
    required this.institution,
    required this.graduationYear,
    required this.fieldOfStudy,
  });

  @override
  List<Object?> get props => [
    degree,
    institution,
    graduationYear,
    fieldOfStudy,
  ];
}

/// Update experience event
class UpdateExperienceEvent extends ProfileEvent {
  final String company;
  final String position;
  final String startDate;
  final String? endDate;
  final String description;

  const UpdateExperienceEvent({
    required this.company,
    required this.position,
    required this.startDate,
    this.endDate,
    required this.description,
  });

  @override
  List<Object?> get props => [
    company,
    position,
    startDate,
    endDate,
    description,
  ];
}

/// Delete experience event
class DeleteExperienceEvent extends ProfileEvent {
  final int index;

  const DeleteExperienceEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

/// Refresh profile data event
class RefreshProfileDataEvent extends ProfileEvent {
  const RefreshProfileDataEvent();

  @override
  List<Object?> get props => [];
}

/// Toggle section expand/collapse event
class ToggleSectionEvent extends ProfileEvent {
  final String section;

  const ToggleSectionEvent({required this.section});

  @override
  List<Object?> get props => [section];
}

/// Delete certificate event
class DeleteCertificateEvent extends ProfileEvent {
  final Map<String, dynamic> certificate;

  const DeleteCertificateEvent({required this.certificate});

  @override
  List<Object?> get props => [certificate];
}

/// Remove profile image event
class RemoveProfileImageEvent extends ProfileEvent {
  const RemoveProfileImageEvent();

  @override
  List<Object?> get props => [];
}

/// Profile builder step events
class UpdateJobTypeEvent extends ProfileEvent {
  final String jobType;

  const UpdateJobTypeEvent({required this.jobType});

  @override
  List<Object?> get props => [jobType];
}

class UpdateExperienceLevelEvent extends ProfileEvent {
  final String experienceLevel;

  const UpdateExperienceLevelEvent({required this.experienceLevel});

  @override
  List<Object?> get props => [experienceLevel];
}

class UpdatePreferredLocationEvent extends ProfileEvent {
  final String preferredLocation;

  const UpdatePreferredLocationEvent({required this.preferredLocation});

  @override
  List<Object?> get props => [preferredLocation];
}

/// Personalize jobfeed events
class UpdateSelectedTradeEvent extends ProfileEvent {
  final String trade;

  const UpdateSelectedTradeEvent({required this.trade});

  @override
  List<Object?> get props => [trade];
}

class UpdateSelectedStateEvent extends ProfileEvent {
  final String state;

  const UpdateSelectedStateEvent({required this.state});

  @override
  List<Object?> get props => [state];
}

class UpdateSelectedCityEvent extends ProfileEvent {
  final String city;

  const UpdateSelectedCityEvent({required this.city});

  @override
  List<Object?> get props => [city];
}

class UpdateSelectedSalaryRangeEvent extends ProfileEvent {
  final String salaryRange;

  const UpdateSelectedSalaryRangeEvent({required this.salaryRange});

  @override
  List<Object?> get props => [salaryRange];
}

class UpdateAvailabilityEvent extends ProfileEvent {
  final String availability;

  const UpdateAvailabilityEvent({required this.availability});

  @override
  List<Object?> get props => [availability];
}

class ToggleJobSectorEvent extends ProfileEvent {
  final String sector;
  final bool isSelected;

  const ToggleJobSectorEvent({required this.sector, required this.isSelected});

  @override
  List<Object?> get props => [sector, isSelected];
}

class ToggleJobTypeEvent extends ProfileEvent {
  final String jobType;
  final bool isSelected;

  const ToggleJobTypeEvent({required this.jobType, required this.isSelected});

  @override
  List<Object?> get props => [jobType, isSelected];
}

class AddSkillEvent extends ProfileEvent {
  final String skill;

  const AddSkillEvent({required this.skill});

  @override
  List<Object?> get props => [skill];
}

class RemoveSkillEvent extends ProfileEvent {
  final String skill;

  const RemoveSkillEvent({required this.skill});

  @override
  List<Object?> get props => [skill];
}

/// Location events
class UpdateSearchQueryEvent extends ProfileEvent {
  final String searchQuery;

  const UpdateSearchQueryEvent({required this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class SelectLocationEvent extends ProfileEvent {
  final String locationName;

  const SelectLocationEvent({required this.locationName});

  @override
  List<Object?> get props => [locationName];
}

/// Location permission events
class RequestLocationPermissionEvent extends ProfileEvent {
  const RequestLocationPermissionEvent();

  @override
  List<Object?> get props => [];
}

class LocationPermissionGrantedEvent extends ProfileEvent {
  const LocationPermissionGrantedEvent();

  @override
  List<Object?> get props => [];
}

class LocationPermissionDeniedEvent extends ProfileEvent {
  const LocationPermissionDeniedEvent();

  @override
  List<Object?> get props => [];
}

/// Change job status tab event
class ChangeJobStatusTabEvent extends ProfileEvent {
  final int tabIndex;

  const ChangeJobStatusTabEvent({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}

/// Update profile edit form event
class UpdateProfileEditFormEvent extends ProfileEvent {
  final String name;
  final String email;
  final String phone;

  const UpdateProfileEditFormEvent({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}

/// Save profile changes event
class SaveProfileChangesEvent extends ProfileEvent {
  const SaveProfileChangesEvent();

  @override
  List<Object?> get props => [];
}

/// Update skills list event
class UpdateSkillsListEvent extends ProfileEvent {
  final List<String> skills;

  const UpdateSkillsListEvent({required this.skills});

  @override
  List<Object?> get props => [skills];
}

/// Save skills changes event
class SaveSkillsChangesEvent extends ProfileEvent {
  const SaveSkillsChangesEvent();

  @override
  List<Object?> get props => [];
}
