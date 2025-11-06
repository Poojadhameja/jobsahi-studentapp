import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../../shared/data/user_data.dart';
import '../../../shared/services/api_service.dart';
import '../models/student_profile.dart';

/// Profile BLoC
/// Handles all profile-related business logic
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    // Register event handlers
    on<LoadProfileDataEvent>(_onLoadProfileData);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
    on<UpdateJobPreferencesEvent>(_onUpdateJobPreferences);
    on<UpdateSkillsEvent>(_onUpdateSkills);
    on<UpdateEducationEvent>(_onUpdateEducation);
    on<UpdateExperienceEvent>(_onUpdateExperience);
    on<DeleteExperienceEvent>(_onDeleteExperience);
    on<RefreshProfileDataEvent>(_onRefreshProfileData);
    on<ToggleSectionEvent>(_onToggleSection);
    on<DeleteCertificateEvent>(_onDeleteCertificate);
    on<RemoveProfileImageEvent>(_onRemoveProfileImage);
    on<UpdateJobTypeEvent>(_onUpdateJobType);
    on<UpdateExperienceLevelEvent>(_onUpdateExperienceLevel);
    on<UpdatePreferredLocationEvent>(_onUpdatePreferredLocation);
    on<UpdateSelectedTradeEvent>(_onUpdateSelectedTrade);
    on<UpdateSelectedStateEvent>(_onUpdateSelectedState);
    on<UpdateSelectedCityEvent>(_onUpdateSelectedCity);
    on<UpdateSelectedSalaryRangeEvent>(_onUpdateSelectedSalaryRange);
    on<UpdateAvailabilityEvent>(_onUpdateAvailability);
    on<ToggleJobSectorEvent>(_onToggleJobSector);
    on<ToggleJobTypeEvent>(_onToggleJobType);
    on<AddSkillEvent>(_onAddSkill);
    on<RemoveSkillEvent>(_onRemoveSkill);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
    on<SelectLocationEvent>(_onSelectLocation);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<LocationPermissionGrantedEvent>(_onLocationPermissionGranted);
    on<LocationPermissionDeniedEvent>(_onLocationPermissionDenied);
    on<ChangeJobStatusTabEvent>(_onChangeJobStatusTab);
    on<UpdateProfileEditFormEvent>(_onUpdateProfileEditForm);
    on<SaveProfileChangesEvent>(_onSaveProfileChanges);
    on<UpdateSkillsListEvent>(_onUpdateSkillsList);
    on<SaveSkillsChangesEvent>(_onSaveSkillsChanges);
  }

  /// Handle load profile data
  Future<void> _onLoadProfileData(
    LoadProfileDataEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());
      var userProfile = Map<String, dynamic>.from(UserData.currentUser);
      var skills = List<String>.from(UserData.currentUser['skills'] ?? []);
      var education = <Map<String, dynamic>>[];
      var experience = <Map<String, dynamic>>[];
      var jobPreferences = <String, dynamic>{
        'preferredJobTypes': UserData.currentUser['preferredJobTypes'] ?? [],
        'preferredLocation': UserData.currentUser['preferredLocation'] ?? '',
        'expectedSalary': UserData.currentUser['expectedSalary'] ?? '',
      };
      var certificates = <Map<String, dynamic>>[
        {
          'name': 'ITI Certificate.pdf',
          'type': 'Certificate',
          'uploadDate': '15 July 2024',
          'size': 1024000,
          'extension': 'pdf',
        },
        {
          'name': 'Safety Training License.pdf',
          'type': 'License',
          'uploadDate': '10 July 2024',
          'size': 850000,
          'extension': 'pdf',
        },
        {
          'name': 'Aadhar Card.jpg',
          'type': 'ID Proof',
          'uploadDate': '5 July 2024',
          'size': 450000,
          'extension': 'jpg',
        },
      ];
      String? profileImagePath = userProfile['profileImage'] as String?;
      String? profileImageName = 'profile_photo.jpg';
      String? resumeFileName = userProfile['resume_file_name'] as String?;
      String? lastResumeUpdatedDate =
          userProfile['resume_last_updated'] as String?;
      final resumeFileSizeRaw = userProfile['resume_file_size'];
      var resumeFileSize = 0;
      if (resumeFileSizeRaw is num) {
        resumeFileSize = resumeFileSizeRaw.toInt();
      } else if (resumeFileSizeRaw is String) {
        final parsedSize = int.tryParse(resumeFileSizeRaw);
        if (parsedSize != null) {
          resumeFileSize = parsedSize;
        }
      }
      var loadedFromApi = false;

      try {
        final apiService = ApiService();
        debugPrint('🔵 [ProfileBloc] Calling getStudentProfile API...');
        final studentProfileResponse = await apiService.getStudentProfile();
        final profiles = studentProfileResponse.data.profiles;

        if (profiles.isNotEmpty) {
          final StudentProfile profile = profiles.first;

          debugPrint(
            '🔵 [ProfileBloc] Profile fetched for user_id: ${profile.userId}',
          );

          final parsedSkills = profile.professionalInfo.skills
              .split(',')
              .map((skill) => skill.trim())
              .where((skill) => skill.isNotEmpty)
              .toList();

          final parsedExperience = profile.professionalInfo.experience
              .map(
                (exp) => {
                  'company': exp.company,
                  'position': exp.role,
                  'startDate': exp.duration.split(' - ').first,
                  'endDate': exp.duration.split(' - ').length > 1
                      ? exp.duration.split(' - ').last
                      : 'Present',
                  'description': exp.description,
                },
              )
              .toList();

          final parsedEducation = <Map<String, dynamic>>[
            {
              'qualification': profile.professionalInfo.education,
              'institute': 'Not specified',
              'course': profile.professionalInfo.trade,
              'passingYear': profile.professionalInfo.graduationYear,
              'cgpa': profile.professionalInfo.cgpa,
            },
          ];

          final jobType = profile.professionalInfo.jobType;
          final normalizedJobTypes =
              jobType.isNotEmpty ? <String>[jobType] : <String>[];

          final resumePath = profile.documents.resume;
          resumeFileName =
              resumePath.isNotEmpty ? resumePath.split('/').last : null;
          lastResumeUpdatedDate = profile.status.modifiedAt;
          resumeFileSize = 0;

          certificates = [];
          if (resumePath.isNotEmpty) {
            certificates.add({
              'name': resumeFileName ?? 'Resume.pdf',
              'type': 'Resume',
              'uploadDate': profile.status.modifiedAt,
              'size': 0,
              'extension': (resumeFileName ?? 'pdf').split('.').last,
              'path': resumePath,
            });
          }

          final certificatePath = profile.documents.certificates;
          if (certificatePath.isNotEmpty) {
            final certificateName = certificatePath.split('/').last;
            certificates.add({
              'name': certificateName,
              'type': 'Certificate',
              'uploadDate': profile.status.modifiedAt,
              'size': 0,
              'extension': certificateName.split('.').last,
              'path': certificatePath,
            });
          }

          userProfile = {
            'id': profile.userId.toString(),
            'name': profile.personalInfo.userName,
            'email': profile.personalInfo.email,
            'phone': profile.personalInfo.phoneNumber,
            'location': profile.personalInfo.location,
            'gender': profile.personalInfo.gender,
            'dateOfBirth': profile.personalInfo.dateOfBirth,
            'bio': profile.additionalInfo.bio,
            'profileImage': null,
            'portfolioLink': profile.socialLinks.portfolioLink,
            'linkedinUrl': profile.socialLinks.linkedinUrl,
            'aadharNumber': profile.documents.aadharNumber,
            'languages': profile.professionalInfo.languages,
            'jobType': profile.professionalInfo.jobType,
            'trade': profile.professionalInfo.trade,
            'graduationYear': profile.professionalInfo.graduationYear,
            'cgpa': profile.professionalInfo.cgpa,
          };

          skills = parsedSkills;
          experience = parsedExperience;
          education = parsedEducation;
          jobPreferences = {
            'preferredJobTypes': normalizedJobTypes,
            'preferredLocation': profile.personalInfo.location,
            'expectedSalary': 'Not specified',
          };
          profileImagePath = null;
          profileImageName = null;

          debugPrint('✅ [ProfileBloc] Profile data loaded successfully from API');
          debugPrint('🔵 [ProfileBloc] Skills count: ${skills.length}');
          debugPrint('🔵 [ProfileBloc] Experience count: ${experience.length}');
          loadedFromApi = true;
        } else {
          debugPrint('⚠️ [ProfileBloc] API returned an empty profile list');
        }
      } catch (e, stackTrace) {
        debugPrint('🔴 [ProfileBloc] API call failed, using fallback data');
        debugPrint('🔴 [ProfileBloc] Error: $e');
        debugPrint('🔴 [ProfileBloc] StackTrace: $stackTrace');
      }

      final sectionExpansionStates = {
        'profile': false,
        'summary': false,
        'education': false,
        'skills': false,
        'experience': false,
        'certificates': false,
        'resume': false,
      };

      if (!loadedFromApi) {
        debugPrint('⚠️ [ProfileBloc] Loading mock/dummy data as fallback');
      }

      emit(
        ProfileDetailsLoaded(
          userProfile: userProfile,
          skills: skills,
          education: education,
          experience: experience,
          jobPreferences: jobPreferences,
          sectionExpansionStates: sectionExpansionStates,
          certificates: certificates,
          profileImagePath: profileImagePath,
          profileImageName: profileImageName,
          resumeFileName: resumeFileName,
          lastResumeUpdatedDate: lastResumeUpdatedDate,
          resumeFileSize: resumeFileSize,
        ),
      );
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  /// Handle update profile
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update mock data (Note: In real app, this would be an API call)
      // UserData.currentUser = updatedProfile; // This is const, so we can't modify it

      emit(ProfileUpdateSuccess(message: 'Profile updated successfully'));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  /// Handle update profile image
  Future<void> _onUpdateProfileImage(
    UpdateProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update mock data (Note: In real app, this would be an API call)
      // UserData.currentUser = updatedProfile; // This is const, so we can't modify it

      emit(ProfileImageUpdateSuccess(imagePath: event.imagePath));
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to update profile image: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle update job preferences
  Future<void> _onUpdateJobPreferences(
    UpdateJobPreferencesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update mock data (Note: In real app, this would be an API call)
      // UserData.jobPreferences = updatedPreferences; // This is const, so we can't modify it

      emit(
        JobPreferencesUpdateSuccess(
          message: 'Job preferences updated successfully',
        ),
      );
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to update job preferences: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle update skills
  Future<void> _onUpdateSkills(
    UpdateSkillsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update skills (Note: In real app, this would be an API call)
      // UserData.userSkills = event.skills; // This is const, so we can't modify it

      emit(SkillsUpdateSuccess(skills: event.skills));
    } catch (e) {
      emit(ProfileError(message: 'Failed to update skills: ${e.toString()}'));
    }
  }

  /// Handle update education
  Future<void> _onUpdateEducation(
    UpdateEducationEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Add education (Note: In real app, this would be an API call)
      // UserData.userEducation.add(newEducation); // This is const, so we can't modify it

      emit(EducationUpdateSuccess(message: 'Education updated successfully'));
    } catch (e) {
      emit(
        ProfileError(message: 'Failed to update education: ${e.toString()}'),
      );
    }
  }

  /// Handle update experience
  Future<void> _onUpdateExperience(
    UpdateExperienceEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Add experience (Note: In real app, this would be an API call)
      // UserData.userExperience.add(newExperience); // This is const, so we can't modify it

      emit(ExperienceUpdateSuccess(message: 'Experience updated successfully'));
    } catch (e) {
      emit(
        ProfileError(message: 'Failed to update experience: ${e.toString()}'),
      );
    }
  }

  /// Handle delete experience
  Future<void> _onDeleteExperience(
    DeleteExperienceEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Delete experience (Note: In real app, this would be an API call)
      // if (event.index >= 0 && event.index < UserData.userExperience.length) {
      //   UserData.userExperience.removeAt(event.index);
      // }

      emit(ExperienceUpdateSuccess(message: 'Experience deleted successfully'));
    } catch (e) {
      emit(
        ProfileError(message: 'Failed to delete experience: ${e.toString()}'),
      );
    }
  }

  /// Handle refresh profile data
  Future<void> _onRefreshProfileData(
    RefreshProfileDataEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // Reload profile data
    add(const LoadProfileDataEvent());
  }

  /// Handle toggle section expand/collapse
  void _onToggleSection(ToggleSectionEvent event, Emitter<ProfileState> emit) {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;
      final updatedExpansionStates = Map<String, bool>.from(
        currentState.sectionExpansionStates,
      );
      updatedExpansionStates[event.section] =
          !(updatedExpansionStates[event.section] ?? false);

      emit(
        currentState.copyWith(sectionExpansionStates: updatedExpansionStates),
      );
    }
  }

  /// Handle delete certificate
  void _onDeleteCertificate(
    DeleteCertificateEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;
      final updatedCertificates = List<Map<String, dynamic>>.from(
        currentState.certificates,
      );
      updatedCertificates.remove(event.certificate);

      emit(currentState.copyWith(certificates: updatedCertificates));

      // Emit success state
      emit(
        const CertificateDeletedSuccess(
          message: 'Certificate deleted successfully!',
        ),
      );
    }
  }

  /// Handle remove profile image
  void _onRemoveProfileImage(
    RemoveProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;

      emit(
        currentState.copyWith(profileImagePath: null, profileImageName: null),
      );

      // Emit success state
      emit(const ProfileImageRemovedSuccess());
    }
  }

  /// Handle update job type
  void _onUpdateJobType(UpdateJobTypeEvent event, Emitter<ProfileState> emit) {
    if (state is ProfileBuilderState) {
      final currentState = state as ProfileBuilderState;
      emit(currentState.copyWith(selectedJobType: event.jobType));
    } else {
      emit(ProfileBuilderState(selectedJobType: event.jobType));
    }
  }

  /// Handle update experience level
  void _onUpdateExperienceLevel(
    UpdateExperienceLevelEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileBuilderState) {
      final currentState = state as ProfileBuilderState;
      emit(
        currentState.copyWith(selectedExperienceLevel: event.experienceLevel),
      );
    } else {
      emit(ProfileBuilderState(selectedExperienceLevel: event.experienceLevel));
    }
  }

  /// Handle update preferred location
  void _onUpdatePreferredLocation(
    UpdatePreferredLocationEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileBuilderState) {
      final currentState = state as ProfileBuilderState;
      emit(
        currentState.copyWith(
          selectedPreferredLocation: event.preferredLocation,
        ),
      );
    } else {
      emit(
        ProfileBuilderState(selectedPreferredLocation: event.preferredLocation),
      );
    }
  }

  /// Handle update selected trade
  void _onUpdateSelectedTrade(
    UpdateSelectedTradeEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedTrade: event.trade));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedTrade: event.trade,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update selected state
  void _onUpdateSelectedState(
    UpdateSelectedStateEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedState: event.state));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedState: event.state,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update selected city
  void _onUpdateSelectedCity(
    UpdateSelectedCityEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedCity: event.city));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedCity: event.city,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update selected salary range
  void _onUpdateSelectedSalaryRange(
    UpdateSelectedSalaryRangeEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedSalaryRange: event.salaryRange));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedSalaryRange: event.salaryRange,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update availability
  void _onUpdateAvailability(
    UpdateAvailabilityEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(availability: event.availability));
    } else {
      emit(
        PersonalizeJobfeedState(
          availability: event.availability,
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle toggle job sector
  void _onToggleJobSector(
    ToggleJobSectorEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedSectors = List<String>.from(currentState.selectedSectors);

      if (event.isSelected) {
        if (!updatedSectors.contains(event.sector)) {
          updatedSectors.add(event.sector);
        }
      } else {
        updatedSectors.remove(event.sector);
      }

      emit(currentState.copyWith(selectedSectors: updatedSectors));
    } else {
      final sectors = event.isSelected ? <String>[event.sector] : <String>[];
      emit(
        PersonalizeJobfeedState(
          availability: 'Immediately Available',
          selectedSectors: sectors,
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle toggle job type
  void _onToggleJobType(ToggleJobTypeEvent event, Emitter<ProfileState> emit) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedJobTypes = List<String>.from(currentState.selectedJobTypes);

      if (event.isSelected) {
        if (!updatedJobTypes.contains(event.jobType)) {
          updatedJobTypes.add(event.jobType);
        }
      } else {
        updatedJobTypes.remove(event.jobType);
      }

      emit(currentState.copyWith(selectedJobTypes: updatedJobTypes));
    } else {
      final jobTypes = event.isSelected ? <String>[event.jobType] : <String>[];
      emit(
        PersonalizeJobfeedState(
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: jobTypes,
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle add skill
  void _onAddSkill(AddSkillEvent event, Emitter<ProfileState> emit) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedSkills = List<String>.from(currentState.skills);
      if (!updatedSkills.contains(event.skill)) {
        updatedSkills.add(event.skill);
      }
      emit(currentState.copyWith(skills: updatedSkills));
    } else {
      emit(
        PersonalizeJobfeedState(
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: [event.skill],
        ),
      );
    }
  }

  /// Handle remove skill
  void _onRemoveSkill(RemoveSkillEvent event, Emitter<ProfileState> emit) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedSkills = List<String>.from(currentState.skills);
      updatedSkills.remove(event.skill);
      emit(currentState.copyWith(skills: updatedSkills));
    }
  }

  /// Handle update search query
  void _onUpdateSearchQuery(
    UpdateSearchQueryEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationState) {
      final currentState = state as LocationState;
      emit(currentState.copyWith(searchQuery: event.searchQuery));
    } else {
      // Initialize with default locations
      final locations = [
        {
          'name': 'Baker Street Library',
          'address': '221B Baker Street London, NW1 6XE United Kingdom',
        },
        {
          'name': 'The Greenfield Mall',
          'address':
              '45 High Street Greenfield, Manchester, M1 2AB United Kingdom',
        },
        {
          'name': 'Riverbank Business Park',
          'address': 'Unit 12, Riverside Drive Bristol, BS1 5RT United Kingdom',
        },
        {
          'name': 'Elmwood Community Centre',
          'address': '78 Elmwood Avenue Birmingham, B12 3DF United Kingdom',
        },
      ];
      emit(LocationState(searchQuery: event.searchQuery, locations: locations));
    }
  }

  /// Handle select location
  void _onSelectLocation(
    SelectLocationEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationState) {
      final currentState = state as LocationState;
      emit(currentState.copyWith(selectedLocation: event.locationName));
    } else {
      // Initialize with default locations
      final locations = [
        {
          'name': 'Baker Street Library',
          'address': '221B Baker Street London, NW1 6XE United Kingdom',
        },
        {
          'name': 'The Greenfield Mall',
          'address':
              '45 High Street Greenfield, Manchester, M1 2AB United Kingdom',
        },
        {
          'name': 'Riverbank Business Park',
          'address': 'Unit 12, Riverside Drive Bristol, BS1 5RT United Kingdom',
        },
        {
          'name': 'Elmwood Community Centre',
          'address': '78 Elmwood Avenue Birmingham, B12 3DF United Kingdom',
        },
      ];
      emit(
        LocationState(
          selectedLocation: event.locationName,
          searchQuery: '',
          locations: locations,
        ),
      );
    }
  }

  /// Handle request location permission
  void _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationPermissionState) {
      final currentState = state as LocationPermissionState;
      emit(currentState.copyWith(isProcessing: true));
    } else {
      emit(
        const LocationPermissionState(
          isProcessing: true,
          permissionGranted: false,
          permissionDenied: false,
        ),
      );
    }
  }

  /// Handle location permission granted
  void _onLocationPermissionGranted(
    LocationPermissionGrantedEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationPermissionState) {
      final currentState = state as LocationPermissionState;
      emit(
        currentState.copyWith(
          isProcessing: false,
          permissionGranted: true,
          permissionDenied: false,
        ),
      );
    } else {
      emit(
        const LocationPermissionState(
          isProcessing: false,
          permissionGranted: true,
          permissionDenied: false,
        ),
      );
    }
  }

  /// Handle location permission denied
  void _onLocationPermissionDenied(
    LocationPermissionDeniedEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationPermissionState) {
      final currentState = state as LocationPermissionState;
      emit(
        currentState.copyWith(
          isProcessing: false,
          permissionGranted: false,
          permissionDenied: true,
        ),
      );
    } else {
      emit(
        const LocationPermissionState(
          isProcessing: false,
          permissionGranted: false,
          permissionDenied: true,
        ),
      );
    }
  }

  /// Handle change job status tab
  void _onChangeJobStatusTab(
    ChangeJobStatusTabEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(JobStatusTabState(selectedTabIndex: event.tabIndex));
  }

  /// Handle update profile edit form
  void _onUpdateProfileEditForm(
    UpdateProfileEditFormEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileEditFormState) {
      final currentState = state as ProfileEditFormState;
      emit(
        currentState.copyWith(
          name: event.name,
          email: event.email,
          phone: event.phone,
        ),
      );
    } else {
      emit(
        ProfileEditFormState(
          name: event.name,
          email: event.email,
          phone: event.phone,
        ),
      );
    }
  }

  /// Handle save profile changes
  Future<void> _onSaveProfileChanges(
    SaveProfileChangesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileEditFormState) {
      final currentState = state as ProfileEditFormState;
      emit(currentState.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      emit(currentState.copyWith(isSaving: false));
      emit(const ProfileChangesSavedState());
    }
  }

  /// Handle update skills list
  void _onUpdateSkillsList(
    UpdateSkillsListEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is SkillsEditFormState) {
      final currentState = state as SkillsEditFormState;
      emit(currentState.copyWith(skills: event.skills));
    } else {
      emit(SkillsEditFormState(skills: event.skills));
    }
  }

  /// Handle save skills changes
  Future<void> _onSaveSkillsChanges(
    SaveSkillsChangesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is SkillsEditFormState) {
      final currentState = state as SkillsEditFormState;
      emit(currentState.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      emit(currentState.copyWith(isSaving: false));
      emit(const SkillsChangesSavedState());
    }
  }
}
